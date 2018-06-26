;-----------------------------------------------------------------------------------------
; NAME:                                                                   IDL Main Program
;   multi_cat_match
;
; PURPOSE:
;   Match several catalogs with multiple calls to CAT_MATCH() and gzip final output.
;
; CALLING SEQUENCE:
;   .r multi_cat_match
;   
; INPUTS:
;   
; OPTIONAL INPUTS:
;   
; OUTPUTS:
;   
; OPTIONAL OUTPUTS:
;  
; COMMENTS:
;   Local directory and file names must be changed for personal use.
;
; EXAMPLES:
;
; PROCEDURES CALLED:
;	
; REVISION HISTORY:
;   2017-May-22  Written by Christopher M. Carroll (Dartmouth)
;-----------------------------------------------------------------------------------------
print, 'Running: MULTI_CAT_MATCH'


;; directories for various catalogs, ordered
sdss_dir = '/Volumes/Dupree/Chris_xMatch_survey/SDSS/DR14/'
zz_dir = '/Volumes/Dupree/Chris_xMatch_survey/xMatch/qso_zsupp/'
xd_dir = '/Volumes/Dupree/Chris_xMatch_survey/XDQSOz/'
wise_dir = '/Volumes/Dupree/Chris_xMatch_survey/WISE/AllWISE/'
unw_dir = '/Volumes/Dupree/Chris_xMatch_survey/WISE/unWISE/'
uk_dir = '/Volumes/Dupree/Chris_xMatch_survey/UKIDSS/DR10/'
;galex_dir = '/Volumes/Dupree/Chris_xMatch_survey/GALEX/DR6/'

;; files within catalog directories
sdss_file = file_search(sdss_dir+'sdss-dr14-cat-part*')
zz_file = file_search(z_dir+'qso-zsupp-cat-part*')
xd_file = file_search(xd_dir+'xdqso-z-cat-part*')
wise_file = file_search(wise_dir+'wise-allwise-cat-part*')
unw_file = file_search(unw_dir+'unwise-dr10sed-cat-part*')
uk_file = file_search(uk_dir+'ukidss-las10-cat-part*')
;galex_file = file_search(galex_dir+'galex-dr6-cat-part*')

;; separate files by 'parts'
sdss_sub = strarr(n_elements(sdss_file))
for i = 0,n_elements(sdss_file)-1 do begin
	temp = strsplit(sdss_file[i],'-.',/extract)
	sdss_sub[i] = temp[-3]
endfor
zz_sub = strarr(n_elements(z_file))
for i = 0,n_elements(zz_file)-1 do begin
	temp = strsplit(zz_file[i],'-.',/extract)
	zz_sub[i] = temp[-3]
endfor
xd_sub = strarr(n_elements(xd_file))
for i = 0,n_elements(xd_file)-1 do begin
	temp = strsplit(xd_file[i],'-.',/extract)
	xd_sub[i] = temp[-3]
endfor
wise_sub = strarr(n_elements(wise_file))
for i = 0,n_elements(wise_file)-1 do begin
	temp = strsplit(wise_file[i],'-.',/extract)
	wise_sub[i] = temp[-3]
endfor
unw_sub = strarr(n_elements(unw_file))
for i = 0,n_elements(unw_file)-1 do begin
	temp = strsplit(unw_file[i],'-.',/extract)
	unw_sub[i] = temp[-3]
endfor
uk_sub = strarr(n_elements(uk_file))
for i = 0,n_elements(uk_file)-1 do begin
	temp = strsplit(uk_file[i],'-.',/extract)
	uk_sub[i] = temp[-3]
endfor
;galex_sub = strarr(n_elements(galex_file))
;for i = 0,n_elements(galex_file)-1 do begin
;	temp = strsplit(galex_file[i],'-.',/extract)
;	galex_sub[i] = temp[3]
;endfor

;; for each input SDSS file, match to all other catalogs
for i = 0,n_elements(sdss_file)-1 do begin
	print, 'MATCHING: '+strupcase(sdss_sub[i])
	print, '    SDSS - '
	sdss = mrdfits(sdss_file[i],1)

	;; Supplement additional redshift data from other work
	print, '    x +Redshift - '
	match,sdss_sub[i],zz_sub,isdss,iz
	if (total(iz) eq -1) then begin
	    zz = mrdfits(zz_file[0],rows=0,1)
	    r = cat_match(r,zz,'_SDSS','_SDSS',0.5,join='SUPPLEMENT',/tags_only)
	endif else begin
	    zz = mrdfits(zz_file[iz],1)
	    r = cat_match(r,zz,'_SDSS','_SDSS',0.5,join='SUPPLEMENT')
	endelse
	undefine,zz
    
    ;; XDQSO
	print, '    x XDQSO - '
	match,sdss_sub[i],xd_sub,isdss,ixd
	if (total(ixd) eq -1) then begin
	    xd = mrdfits(xd_file[0],rows=0,1)
	    r = cat_match(sdss,xd,'_SDSS','_XDQSO',0.5,join='OUTER',/tags_only)
    endif else begin
		xd = mrdfits(xd_file[ixd],1)
	    r = cat_match(sdss,xd,'_SDSS','_XDQSO',0.5,join='OUTER')
	endelse
	undefine,sdss,xd

	;; WISE
	print, '    x WISE - '
	match,sdss_sub[i],wise_sub,isdss,iwise
	if (total(iwise) eq -1) then begin
	    wise = mrdfits(wise_file[0],rows=0,1)
	    r = cat_match(r,wise,'','_WISE',3.0,join='INNER',/tags_only)
	endif else begin
	    wise = mrdfits(wise_file[iwise],1)
	    r = cat_match(r,wise,'','_WISE',3.0,join='INNER')
	endelse
	undefine,wise
	
	;; unWISE
	print, '    x unWISE - '
	match,sdss_sub[i],unw_sub,isdss,iunw
	if (total(iunw) eq -1) then begin
	    unw = mrdfits(unw_file[0],rows=0,1)
	    r = cat_match(r,unw,'','_UNWISE',0.5,join='LEFT',/tags_only)
	endif else begin
	    unw = mrdfits(unw_file[iunw],1)
	    r = cat_match(r,unw,'','_UNWISE',0.5,join='LEFT')
	endelse
	undefine,unw
	
	;; UKIDSS
	print, '    x UKIDSS - '
	match,sdss_sub[i],uk_sub,isdss,iuk
	if (total(iuk) eq -1) then begin
	    uk = mrdfits(uk_file[0],rows=0,1) else $
	    r = cat_match(r,uk_all,'','_UKIDSS',3.0,join='LEFT',/tags_only)
	endif else begin
	    uk = mrdfits(uk_file[iuk],1)
	    r = cat_match(r,uk_all,'','_UKIDSS',3.0,join='LEFT')
	endelse
	undefine,uk
	
	;; GALEX
;	print, '    x GALEX - '
;	match,sdss_sub[i],galex_sub,isdss,igalex
;	if (total(igalex) eq -1) then galex = mrdfits(galex_file[0],rows=0,1) else $
;	                              galex = mrdfits(galex_file[igalex],1)
;	r = cat_match(r,galex,'','_GALEX',3.0,join='LEFT')
;	undefine,galex
;		
	mwrfits,r,'sdssXwise-NIR-cat-'+sdss_sub[i]+'.fits',/CREATE
	spawn,'for file in *.fits; do gzip "$file"; done'
endfor


END




