#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2153,SC2154
declare -rx PS4='+${SECONDS}s $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]: '
set -x
cpreq="ln -snf"
cpreq=${cpreq:-cpreq}
#
# timestr=$(date -d "${CDATE:0:8} ${CDATE:8:2}" +%Y-%m-%d_%H.%M.%S) 
lbc_interval=${LBC_INTERVAL:-3}
#
# find forecst length for this cycle
#
fcst_len_hrs_cycles=${FCST_LEN_HRS_CYCLES:-"01 01"}
fcst_len_hrs_thiscyc=$( "${USHrrfs}/find_fcst_length.sh"  "${fcst_len_hrs_cycles}" "${cyc}" )
echo "forecast length for this cycle is ${fcst_len_hrs_thiscyc}"
lbc_hrs=$(( 10#${PREP_LBC_LOOK_BACK_HRS} ))
#
# find cycle that has boundary files
#
CDATElbcend=$( ${NDATE} $((10#${fcst_len_hrs_thiscyc})) "${CDATE}")
string_time=$(date -d "${CDATElbcend:0:8} ${CDATElbcend:8:2}" +%Y-%m-%d_%H.%M.%S)
last_bdyfile="lbc.${string_time}.nc"
last_bdyfile_chem="lbc.chem.${string_time}.nc"
n=0
while (( n <= lbc_hrs )); do
  CDATElbc=$(${NDATE} -$((10#${n})) "${CDATE}")
  YYYYMMDDlbc=${CDATElbc:0:8}
  HHlbc=${CDATElbc:8:2}
  checkfile=${COMINrrfs}/${RUN}.${YYYYMMDDlbc}/${HHlbc}/lbc/${WGF}${MEMDIR}/${last_bdyfile}
  checkfile_chem=${COMINrrfs}/${RUN}.${YYYYMMDDlbc}/${HHlbc}/lbc_chem/${WGF}${MEMDIR}/${last_bdyfile_chem}
  if [[ -s "${checkfile}" ]]; then
     echo "Found ${checkfile}; Use it as boundary for forecast "
     break
  else
     n=$((n + 1))
  fi
done

#
# find bdry sequence and copy them to umbrella space
#

fhr_all=$(seq 0 $((10#${lbc_interval})) $((10#${fcst_len_hrs_thiscyc} )) )

if [[ -s "${checkfile}" ]]; then
  for fhr in  ${fhr_all}; do
    CDATElbc=$(${NDATE} "${fhr}" "${CDATE}")
    string_time=$(date -d "${CDATElbc:0:8} ${CDATElbc:8:2}" +%Y-%m-%d_%H.%M.%S)
    ${cpreq} "${COMINrrfs}/${RUN}.${YYYYMMDDlbc}/${HHlbc}/lbc/${WGF}${MEMDIR}/lbc.${string_time}.nc"  "${UMBRELLA_PREP_LBC_DATA}/."
  done
else
  echo "Cannot find boundary file: ${checkfile}"
  err_exit
fi

if [[ -s "${checkfile_chem}" ]]; then
  for fhr in  ${fhr_all}; do
    CDATElbc=$(${NDATE} "${fhr}" "${CDATE}")
    string_time=$(date -d "${CDATElbc:0:8} ${CDATElbc:8:2}" +%Y-%m-%d_%H.%M.%S)
    ${cpreq} "${COMINrrfs}/${RUN}.${YYYYMMDDlbc}/${HHlbc}/lbc/${WGF}${MEMDIR}/lbc.${string_time}.nc"  "${UMBRELLA_PREP_LBC_DATA}/."
    ncks -A -v lbc_dust_fine,lbc_dust_coarse "${COMINrrfs}/${RUN}.${YYYYMMDDlbc}/${HHlbc}/lbc_chem/${WGF}${MEMDIR}/lbc.chem.${string_time}.nc" "${UMBRELLA_PREP_LBC_DATA}/lbc.${string_time}.nc"
    # Only for GEFS-Aerosols due to the unit missmatch
    # Scalling factor may need to modified for other models
    ncap2 -s 'lbc_dust_fine=lbc_dust_fine*1e-9; lbc_dust_coarse=lbc_dust_coarse*1e-9' -O "${UMBRELLA_PREP_LBC_DATA}/lbc.${string_time}.nc" "${UMBRELLA_PREP_LBC_DATA}/lbc.${string_time}.nc"
  done
else
  echo "No external chemical boundary files"
fi
