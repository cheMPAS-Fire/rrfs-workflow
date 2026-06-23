#!/bin/bash

HPSS_location=/BMC/rtrr/5year/mpas_fire

if [ ${#FILE_TMPL2} -gt 0 ]; then
   htar -cvf ${HPSS_location}/${CDATE}_grib2.tar ${COMOUT}/upp/${FILE_TMPL1} ${COMOUT}/upp/${FILE_TMPL2}
else
   htar -cvf ${HPSS_location}/${CDATE}_grib2.tar ${COMOUT}/upp/${FILE_TMPL1}
fi
