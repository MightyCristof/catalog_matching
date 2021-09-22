;-----------------------------------------------------------------------------------------
; NAME:                                                                       IDL Function
;	match2xcat
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
PRO match2xcat, file, $
                ra_str, $
                dec_str, $
                sep
                

;; path to xMatch catalog
xcat_dir = '/Users/ccarroll/Research/surveys/x-Match/SDSSxWISE'

;; read data
r = mrdfits(file,1)
tags = tag_names(r)
idec = where(strmatch(tags,dec_str))

;; make a temporary directory to split file by declination
temp_dir = 'temp_'+file+'_data'
file_mkdir, temp_dir
pushd, temp_dir

;; separate file by WISE declination
match2wise_dec,'../'+file,'part',idec+1
;; match to xMatch catalog
;; all catalogs
cat = [file, $
       'XMATCH']
catlen = n_elements(cat)

;; catalog directories
cat_dir = cat+'_DIR'
dir = ['./', $
       '/Users/ccarroll/Research/surveys/x-Match/SDSSxWISE/']
;; catalog files
cat_file = cat+'_FILE'
;; catalog indices
cat_ind = 'I'+cat
;; catalog suffix
cat_suff = cat+'_SUFF'
;; catalog join type
cat_join = cat+'_JOIN'
;;      YSE    xMatch
join = ['NONE','LEFT']
;; catalog separation
cat_sep = cat+'_SEP'

cat_part = cat+'_PART'
for i = 0,catlen-1 do begin
    re = execute(cat_dir[i]+' = dir[i]')
    re = execute(cat_file[i]+' = file_search('+cat_dir[i]+'+"*part*")')
    re = execute(cat_part[i]+' = strarr(n_elements('+cat_file[i]+'))')
    re = execute('nparts = n_elements('+cat_part[i]+')')
    for p = 0,nparts-1 do begin
        re = execute('temp = strsplit('+cat_file[i]+'[p],"-.",/extract)')
        ipart = where(strmatch(temp,'part*'),plen)
        if (plen eq 0) then continue else $
                            re = execute(cat_part[i]+'[p] = temp[ipart]')
    endfor
endfor








part_file = file_search()
nparts = n_elements(part_file)
xcat_part = file_search(xcat_dir+'/*')
for i = 0,nparts-1 do begin
        



endfor


END

