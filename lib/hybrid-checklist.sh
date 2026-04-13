#!/usr/bin/env bash
# Apigee Hybrid v1.16 install checklist — automated checks for steps 5–13 (cshell hybrid --check).
# Expects: command_exists; PROJECT_ID, ORG_NAME, APIGEE_HELM_CHARTS_HOME, APIGEE_NAMESPACE; optional CONTROL_PLANE_LOCATION.
# shellcheck shell=bash
# Sets HYBRID_STEP{5..13}_{SYM,NOTE} for the cshell caller (not used within this file).
# shellcheck disable=SC2034

HYBRID_PROD_SA_SUFFIXES=(
	logger
	guardrails
	metrics
	watcher
	mart
	synchronizer
	runtime
)

cshell_hybrid_kubectl_cluster_ok() {
	command_exists kubectl || return 1
	kubectl cluster-info --request-timeout=5s &>/dev/null
}

cshell_hybrid_kubectl_ns_ok() {
	[[ -n "${APIGEE_NAMESPACE:-}" ]] || return 1
	kubectl get namespace "${APIGEE_NAMESPACE}" --request-timeout=5s &>/dev/null
}

cshell_hybrid_gcloud_sa_emails() {
	command_exists gcloud || return 1
	[[ -n "${PROJECT_ID:-}" ]] || return 1
	gcloud iam service-accounts list --project="${PROJECT_ID}" --format='value(email)' 2>/dev/null
}

# Non-prod path: non-prod key file on disk OR non-prod K8s secret exists (implies env).
cshell_hybrid_detect_nonprod() {
	local charts="${APIGEE_HELM_CHARTS_HOME:-}"
	local sa_json=""
	if [[ -n "${charts}" && -n "${PROJECT_ID:-}" ]]; then
		sa_json="${charts}/service-accounts/${PROJECT_ID}-apigee-non-prod.json"
	fi
	if [[ -n "${sa_json}" && -f "${sa_json}" ]]; then
		return 0
	fi
	if cshell_hybrid_kubectl_cluster_ok && cshell_hybrid_kubectl_ns_ok; then
		kubectl get secret apigee-non-prod-svc-account -n "${APIGEE_NAMESPACE}" --request-timeout=5s &>/dev/null && return 0
	fi
	return 1
}

cshell_hybrid_certs_dir_has_material() {
	local d="${APIGEE_HELM_CHARTS_HOME:-}/apigee-virtualhost/certs"
	[[ -d "${d}" ]] || return 1
	local crt=0 key=0 f
	shopt -s nullglob
	for f in "${d}"/*.crt "${d}"/*.pem; do
		[[ -f "${f}" ]] && crt=1
	done
	for f in "${d}"/*.key; do
		[[ -f "${f}" ]] && key=1
	done
	shopt -u nullglob
	((crt == 1 && key == 1))
}

cshell_hybrid_count_prod_keyfiles() {
	local sa_dir="$1"
	local count=0 sfx
	[[ -d "${sa_dir}" && -n "${PROJECT_ID:-}" ]] || {
		printf '%s\n' 0
		return 0
	}
	for sfx in "${HYBRID_PROD_SA_SUFFIXES[@]}"; do
		[[ -f "${sa_dir}/${PROJECT_ID}-apigee-${sfx}.json" ]] && count=$((count + 1))
	done
	printf '%s\n' "${count}"
}

cshell_hybrid_count_prod_sa_emails() {
	local emails="$1"
	local found=0 sfx
	[[ -n "${emails}" ]] || {
		printf '%s\n' 0
		return 0
	}
	for sfx in "${HYBRID_PROD_SA_SUFFIXES[@]}"; do
		if grep -q "apigee-${sfx}@" <<<"${emails}"; then
			found=$((found + 1))
		fi
	done
	printf '%s\n' "${found}"
}

# Sets HYBRID_STEP5_SYM HYBRID_STEP5_NOTE … HYBRID_STEP13_SYM HYBRID_STEP13_NOTE using sym_{done,fail,skip} names.
cshell_hybrid_eval_checklist_steps_5_13() {
	local sym_done="$1" sym_fail="$2" sym_skip="$3"
	local community_url="$4"

	# --- Step 5: Service accounts (GCP / key files) ---
	HYBRID_STEP5_SYM="${sym_skip}"
	HYBRID_STEP5_NOTE=""
	local charts="${APIGEE_HELM_CHARTS_HOME:-}"
	local sa_dir=""
	[[ -n "${charts}" ]] && sa_dir="${charts}/service-accounts"
	local emails="" gcloud_ok=0
	if emails=$(cshell_hybrid_gcloud_sa_emails); then
		gcloud_ok=1
	fi
	local have_sa_dir=0
	[[ -n "${sa_dir}" && -d "${sa_dir}" ]] && have_sa_dir=1

	if cshell_hybrid_detect_nonprod; then
		local ok_np=0
		if [[ -n "${PROJECT_ID:-}" && -f "${sa_dir}/${PROJECT_ID}-apigee-non-prod.json" ]]; then
			ok_np=1
		fi
		if ((gcloud_ok == 1)) && grep -q "apigee-non-prod@" <<<"${emails}"; then
			ok_np=1
		fi
		if ((ok_np == 1)); then
			HYBRID_STEP5_SYM="${sym_done}"
		elif ((gcloud_ok == 0)) && ((have_sa_dir == 0)); then
			HYBRID_STEP5_SYM="${sym_skip}"
			HYBRID_STEP5_NOTE="no service-accounts/ directory and gcloud unavailable (Vault/WI/offline?)"
		else
			HYBRID_STEP5_SYM="${sym_fail}"
			HYBRID_STEP5_NOTE="non-prod Apigee SA or key file not found (apigee-non-prod)"
		fi
	else
		local json_count
		json_count="$(cshell_hybrid_count_prod_keyfiles "${sa_dir}")"
		if ((json_count == 7)); then
			HYBRID_STEP5_SYM="${sym_done}"
		elif ((gcloud_ok == 1)); then
			local found_sa
			found_sa="$(cshell_hybrid_count_prod_sa_emails "${emails}")"
			if ((found_sa == 7)); then
				HYBRID_STEP5_SYM="${sym_done}"
			elif ((found_sa > 0 && found_sa < 7)); then
				HYBRID_STEP5_SYM="${sym_fail}"
				HYBRID_STEP5_NOTE="only ${found_sa}/7 production Apigee service accounts in project"
			elif ((have_sa_dir == 1)); then
				HYBRID_STEP5_SYM="${sym_fail}"
				HYBRID_STEP5_NOTE="only ${json_count}/7 production key files under service-accounts/"
			else
				HYBRID_STEP5_SYM="${sym_fail}"
				HYBRID_STEP5_NOTE="production Apigee service accounts not found in project"
			fi
		elif ((have_sa_dir == 1)) && ((json_count > 0 && json_count < 7)); then
			HYBRID_STEP5_SYM="${sym_fail}"
			HYBRID_STEP5_NOTE="only ${json_count}/7 production key files under service-accounts/"
		elif ((have_sa_dir == 0)) && ((gcloud_ok == 0)); then
			HYBRID_STEP5_SYM="${sym_skip}"
			HYBRID_STEP5_NOTE="no service-accounts/ directory and gcloud unavailable (Vault/WI/offline?)"
		else
			HYBRID_STEP5_SYM="${sym_fail}"
			HYBRID_STEP5_NOTE="production requires 7 key files or matching gcloud SAs (found ${json_count})"
		fi
	fi

	# --- Step 6: K8s secrets for SA auth ---
	HYBRID_STEP6_SYM="${sym_skip}"
	HYBRID_STEP6_NOTE=""
	if ! command_exists kubectl; then
		HYBRID_STEP6_NOTE="kubectl not in PATH"
	elif ! cshell_hybrid_kubectl_cluster_ok; then
		HYBRID_STEP6_NOTE="cluster not reachable"
	elif ! cshell_hybrid_kubectl_ns_ok; then
		HYBRID_STEP6_NOTE="namespace not available"
	else
		if cshell_hybrid_detect_nonprod; then
			if kubectl get secret apigee-non-prod-svc-account -n "${APIGEE_NAMESPACE}" --request-timeout=5s &>/dev/null; then
				HYBRID_STEP6_SYM="${sym_done}"
			else
				HYBRID_STEP6_SYM="${sym_fail}"
				HYBRID_STEP6_NOTE="secret apigee-non-prod-svc-account missing"
			fi
		else
			local sfx missing=0
			for sfx in "${HYBRID_PROD_SA_SUFFIXES[@]}"; do
				if ! kubectl get secret "apigee-${sfx}-svc-account" -n "${APIGEE_NAMESPACE}" --request-timeout=5s &>/dev/null; then
					missing=1
					break
				fi
			done
			if ((missing == 0)); then
				HYBRID_STEP6_SYM="${sym_done}"
			else
				HYBRID_STEP6_SYM="${sym_fail}"
				HYBRID_STEP6_NOTE="one or more apigee-*-svc-account secrets missing (production set)"
			fi
		fi
	fi

	# --- Step 7: TLS ---
	HYBRID_STEP7_SYM="${sym_fail}"
	HYBRID_STEP7_NOTE=""
	if cshell_hybrid_certs_dir_has_material; then
		HYBRID_STEP7_SYM="${sym_done}"
	elif command_exists kubectl && cshell_hybrid_kubectl_cluster_ok && cshell_hybrid_kubectl_ns_ok; then
		local cert_lines tls_types
		cert_lines="$(kubectl get certificate -n "${APIGEE_NAMESPACE}" --request-timeout=5s 2>/dev/null | awk 'NR>1' || true)"
		tls_types="$(kubectl get secrets -n "${APIGEE_NAMESPACE}" --request-timeout=5s -o jsonpath='{.items[*].type}' 2>/dev/null || true)"
		if [[ -n "${cert_lines//[[:space:]]/}" ]] || grep -q 'kubernetes.io/tls' <<<"${tls_types}"; then
			HYBRID_STEP7_SYM="${sym_done}"
		else
			HYBRID_STEP7_NOTE="no certs in apigee-virtualhost/certs/, no Certificate CR, no TLS secret"
		fi
	elif ! cshell_hybrid_certs_dir_has_material; then
		HYBRID_STEP7_SYM="${sym_skip}"
		if command_exists kubectl && ! cshell_hybrid_kubectl_cluster_ok; then
			HYBRID_STEP7_NOTE="cluster not reachable; apigee-virtualhost/certs/ missing or incomplete"
		elif command_exists kubectl && ! cshell_hybrid_kubectl_ns_ok; then
			HYBRID_STEP7_NOTE="namespace not available; apigee-virtualhost/certs/ missing or incomplete"
		else
			HYBRID_STEP7_NOTE="no TLS material under apigee-virtualhost/certs/ (kubectl unavailable)"
		fi
	fi

	# --- Step 8: overrides.yaml ---
	HYBRID_STEP8_SYM="${sym_fail}"
	HYBRID_STEP8_NOTE=""
	local ov="${charts}/overrides.yaml"
	if [[ -f "${ov}" && -s "${ov}" ]]; then
		HYBRID_STEP8_SYM="${sym_done}"
	else
		HYBRID_STEP8_NOTE="missing or empty overrides.yaml under APIGEE_HELM_CHARTS_HOME"
	fi

	# --- Step 9: Control plane access (Apigee API) ---
	HYBRID_STEP9_SYM="${sym_skip}"
	HYBRID_STEP9_NOTE=""
	if ! command_exists gcloud || ! command_exists curl; then
		HYBRID_STEP9_NOTE="gcloud or curl not in PATH"
	else
		local token http_code body tmp
		token="$(gcloud auth print-access-token 2>/dev/null || true)"
		if [[ -z "${token}" ]]; then
			HYBRID_STEP9_NOTE="gcloud auth print-access-token failed"
		else
			local base="https://apigee.googleapis.com"
			[[ -n "${CONTROL_PLANE_LOCATION:-}" ]] && base="https://${CONTROL_PLANE_LOCATION}-apigee.googleapis.com"
			# ORG_NAME is loaded from ~/.cshell.env before the checklist runs (not a local misspelling).
			# shellcheck disable=SC2153
			local url="${base}/v1/organizations/${ORG_NAME}/controlPlaneAccess"
			tmp="$(mktemp "${TMPDIR:-/tmp}/cshell-hybrid-cp.XXXXXX")"
			http_code="$(curl -sS -o "${tmp}" -w '%{http_code}' --max-time 15 -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" "${url}" 2>/dev/null || printf '%s' '000')"
			body="$(cat "${tmp}" 2>/dev/null || true)"
			rm -f "${tmp}"
			if [[ "${http_code}" != "200" ]]; then
				HYBRID_STEP9_SYM="${sym_skip}"
				HYBRID_STEP9_NOTE="Apigee controlPlaneAccess HTTP ${http_code} (auth/residency/network)"
			elif grep -qE '"synchronizerIdentities"[[:space:]]*:[[:space:]]*\[\]' <<<"${body}" \
				|| grep -qE '"synchronizerIdentities"[[:space:]]*:[[:space:]]*null' <<<"${body}"; then
				HYBRID_STEP9_SYM="${sym_fail}"
				HYBRID_STEP9_NOTE="controlPlaneAccess returned empty synchronizer identities"
			elif grep -q 'synchronizerIdentities' <<<"${body}" && grep -q 'serviceAccount:' <<<"${body}"; then
				HYBRID_STEP9_SYM="${sym_done}"
			else
				HYBRID_STEP9_SYM="${sym_fail}"
				HYBRID_STEP9_NOTE="unexpected controlPlaneAccess response (no synchronizer service accounts)"
			fi
		fi
	fi

	# --- Step 10: cert-manager ---
	HYBRID_STEP10_SYM="${sym_skip}"
	HYBRID_STEP10_NOTE=""
	if ! command_exists kubectl || ! cshell_hybrid_kubectl_cluster_ok; then
		HYBRID_STEP10_NOTE="kubectl unavailable or cluster not reachable"
	elif ! kubectl get crd certificates.cert-manager.io --request-timeout=5s &>/dev/null; then
		HYBRID_STEP10_SYM="${sym_fail}"
		HYBRID_STEP10_NOTE="cert-manager CRD certificates.cert-manager.io not found"
	elif kubectl get namespace cert-manager --request-timeout=5s &>/dev/null; then
		local pod_lines
		pod_lines="$(kubectl get pods -n cert-manager --request-timeout=5s --no-headers 2>/dev/null | wc -l | tr -d ' ')"
		if [[ "${pod_lines:-0}" -ge 1 ]]; then
			HYBRID_STEP10_SYM="${sym_done}"
		else
			HYBRID_STEP10_SYM="${sym_fail}"
			HYBRID_STEP10_NOTE="cert-manager namespace has no pods"
		fi
	else
		HYBRID_STEP10_SYM="${sym_fail}"
		HYBRID_STEP10_NOTE="cert-manager namespace missing"
	fi

	# --- Step 11: Apigee CRDs ---
	HYBRID_STEP11_SYM="${sym_skip}"
	HYBRID_STEP11_NOTE=""
	if ! command_exists kubectl || ! cshell_hybrid_kubectl_cluster_ok; then
		HYBRID_STEP11_NOTE="kubectl unavailable or cluster not reachable"
	elif kubectl get crd apigeeorganizations.apigee.cloud.google.com --request-timeout=5s &>/dev/null; then
		HYBRID_STEP11_SYM="${sym_done}"
	else
		HYBRID_STEP11_SYM="${sym_fail}"
		HYBRID_STEP11_NOTE="Apigee CRDs not installed (apigeeorganizations… not found)"
	fi

	# --- Step 12: Helm releases ---
	HYBRID_STEP12_SYM="${sym_skip}"
	HYBRID_STEP12_NOTE=""
	if ! command_exists helm; then
		HYBRID_STEP12_NOTE="helm not in PATH"
	elif ! cshell_hybrid_kubectl_cluster_ok; then
		HYBRID_STEP12_NOTE="cluster not reachable"
	elif helm list -n "${APIGEE_NAMESPACE}" -q 2>/dev/null | grep -q 'apigee-operator'; then
		HYBRID_STEP12_SYM="${sym_done}"
	else
		HYBRID_STEP12_SYM="${sym_fail}"
		HYBRID_STEP12_NOTE="Helm release apigee-operator not found in namespace ${APIGEE_NAMESPACE}"
	fi

	# --- Step 13: Official install hub URL reachability ---
	HYBRID_STEP13_SYM="${sym_skip}"
	HYBRID_STEP13_NOTE=""
	local ccode
	ccode="$(curl -sSI -o /dev/null -w '%{http_code}' --max-time 5 "${community_url}" 2>/dev/null || printf '%s' '000')"
	if [[ "${ccode}" =~ ^2 ]]; then
		HYBRID_STEP13_SYM="${sym_done}"
	else
		HYBRID_STEP13_NOTE="official install hub URL not reachable (HTTP ${ccode}; offline?)"
	fi
}
