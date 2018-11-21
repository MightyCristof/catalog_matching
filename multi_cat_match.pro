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
;   Individual catalogs must be sorted by section on the sky with the string 'part', 
;   (e.g., sdss-dr14-cat-part16.fits).
;	
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


;; all catalogs
cat = ['SDSS','ZSUPP','XDQSO','WISE','UNWISE','UKIDSS','GALEX']
catlen = n_elements(cat)

;; catalog directories
cat_dir = cat+'_DIR'
dir = ['/Volumes/Dupree/Chris_xMatch_survey/SDSS/DR14/', $
       '/Volumes/Dupree/Chris_xMatch_survey/xMatch/qso_zsupp/', $
       '/Volumes/Dupree/Chris_xMatch_survey/XDQSOz/', $
       '/Volumes/Dupree/Chris_xMatch_survey/WISE/AllWISE/', $
       '/Volumes/Dupree/Chris_xMatch_survey/WISE/unWISE/', $
       '/Volumes/Dupree/Chris_xMatch_survey/UKIDSS/DR10/', $
       '/Volumes/Dupree/Chris_xMatch_survey/GALEX/DR6/' $
       ]
;; catalog files
cat_file = cat+'_FILE'
;; catalog indices
cat_ind = 'I'+cat
;; catalog suffix
cat_suff = cat+'_SUFF'
;; catalog join type
cat_join = cat+'_JOIN'
join = ['NONE','SUPPLEMENT','OUTER','INNER','LEFT','LEFT','LEFT']
;; catalog separation
cat_sep = cat+'_SEP'
sep = [0.,0.5,0.5,3.0,0.5,3.,3.]

;; sky sections by 'parts'
cat_part = cat+'_PART'
for i = 0,catlen-1 do begin
    re = execute(cat_dir[i]+' = dir[i]')
    re = execute(cat_file[i]+' = file_search('+cat_dir[i]+'+"*part*")')
    re = execute(cat_part[i]+' = strarr(n_elements('+cat_file[i]+'))')
    re = execute('nparts = n_elements('+cat_part[i]+')')
    for p = 0,nparts-1 do begin
        re = execute('temp = strsplit('+cat_file[i]+'[p],"-.",/extract)')
        ipart = where(strmatch(temp,'part*'),plen)
        if (plen eq 0) then stop else $
                            re = execute(cat_part[i]+'[p] = temp[ipart]')
    endfor
endfor

;; create catalog match input parameters
for i = 0,catlen-1 do begin
    re = execute(cat_suff[i]+' = "_"+cat[i]')
    re = execute(cat_join[i]+' = join[i]')
    re = execute(cat_sep[i]+' = sep[i]')
endfor

;; for each input SDSS file, match to all other catalogs
re = execute('nparts = n_elements('+cat_part[0]+')')
for i = 0,nparts-1 do begin
    re = execute('print, "MATCHING: "+strupcase('+cat_part[0]+'[i])')
	re = execute('print, "    "+cat[0]+" - "')
	re = execute('r = mrdfits('+cat_file[0]+'[i],1,/silent)')
    ;; match to other catalogs
    for j = 1,catlen-1 do begin
	    print, '         x '+cat[j]
	    re = execute('match,'+cat_part[0]+'[i],'+cat_part[j]+','+cat_ind[0]+','+cat_ind[j])
	    re = execute('ind = '+cat_ind[0])
	    if (total(where(strmatch(tag_names(r),'RA'))) eq -1) then re = execute('cat_suff0 = '+cat_suff[0]) else $
	                                                              cat_suff0 = ''
	    if (ind eq -1) then begin
            re = execute(cat[j]+' = mrdfits('+cat_file[j]+'[0],rows=0,1,/silent)')
            re = execute('r = cat_match(r,'+cat[j]+',cat_suff0,'+cat_suff[j]+','+cat_sep[j]+',join='+cat_join[j]+',/tags_only)')
	    endif else begin
            re = execute(cat[j]+' = mrdfits('+cat_file[j]+'['+cat_ind[j]+'],1,/silent)')
            re = execute('r = cat_match(r,'+cat[j]+',cat_suff0,'+cat_suff[j]+','+cat_sep[j]+',join='+cat_join[j]+')')
	    endelse
	    ;re = execute('undefine,'+cat[j])
    endfor
	
	re = execute('mwrfits,r,"sdssXwise-NIR-GALEX-"+'+cat_part[0]+'[i]+".fits",/CREATE')	
endfor
spawn,'for file in *.fits; do gzip "$file"; done'


END




