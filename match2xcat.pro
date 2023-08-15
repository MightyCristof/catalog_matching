;-----------------------------------------------------------------------------------------
; NAME:                                                                       IDL Function
;	match2ccat
;   
; PURPOSE:
;   
;
; CALLING SEQUENCE:
;   
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;   
;
; OUTPUTS:
;   
;
; OPTIONAL OUTPUTS:
;  
; COMMENTS:
;   
;
; EXAMPLES:
;   
; PROCEDURES CALLED:
;	
;
; REVISION HISTORY:
;   2021-Sep-21  Written by Christopher M. Carroll (Dartmouth)
;-----------------------------------------------------------------------------------------
PRO match2ccat, file, $
                ra_str, $
                dec_str, $
                sep, 
                CLEAN = clean
                

;; read data
data = mrdfits(file,1)
tags = tag_names(data)
idec = where(strmatch(tags,dec_str))

;; make a temporary directory to split file by declination
temp_dir = 'temp_'+file+'_data'
file_mkdir, temp_dir
pushd, temp_dir

;; separate file by WISE declination
match2wise_dec,'../'+file,'part',idec+1

;; pdata parts array for matching
data_file = file_search()
ndata = n_elements(data_file)
data_part = strarr(ndata)
for i = 0,ndata-1 do begin
    temp = strsplit(data_file[i],'-.',/extract)
    ipart = where(strmatch(temp,'part*'),plen)
    data_part[i] = temp[ipart]
endfor

;; ccat parts array for matching
ccat_dir = '/Users/ccarroll/Research/surveys/x-Match/SDSSxWISE'
ccat_file = file_search(ccat_dir+'/*.fits.gz') 
nccat = n_elements(ccat_file)
ccat_part = strarr(nccat)
for i = 0,nccat-1 do begin
    temp = strsplit(ccat_file[i],'-.',/extract)
    ipart = where(strmatch(temp,'part*'),plen)
    ccat_part[i] = temp[ipart]
endfor

for i = 0,ndata-1 do begin
    print, 'MATCHING: '+data_part[i]
    match,data_part[i],ccat_part,idata,iccat
    if (idata eq -1) then continue
	rdata = mrdfits(data_file[i],1,/silent)
	rccat = mrdfits(ccat_file[iccat],1,/silent)
    ;; match data to ccat
    r = cat_match(rdata,rccat,(strsplit(ra_str,'RA*',/regex,/extract))[0],'',sep,join='LEFT')
    mwrfits,r,data_file[i],/create
endfor

;; concatenate
rr = mrdfits(data_file[0],1)
for i = 1,ndata-1 do rr = [rr,mrdfits(data_file[i],1)]

;; write to file
popd
mwrfits,rr,(strsplit(file,'.fits',/regex,/extract))[0]+'_xmatch.fits',/create

;; clean up
if keyword_set(clean) then file_delete, temp_dir, /recursive


END




