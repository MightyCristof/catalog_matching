;-----------------------------------------------------------------------------------------
; NAME:                                                                       IDL Function
;   nrows_in_fits
;   
; PURPOSE:
;   Return the number of rows in a given FITS file, or array of FITS files.
;   
; CALLING SEQUENCE:
;   nrows = nrows_in_fits( files, [, /CUM ] )
;	
; INPUTS:
;   files			- Input string or string array of FITS files.
;   
; OPTIONAL INPUTS:
;   CUM             - Cumulative sum for array of input FITS files.
; OUTPUTS:
;   rows			- Vector with length matching files, containing the number
;                     of rows in each FITS file.
;   
; OPTIONAL OUTPUTS:
;  
; COMMENTS:
;   Can accept wildcard character [e.g., nrows_in_fits("*16*.fits")].
;	A call of "*" will automatically revert to a cumulative sum.
;   
; EXAMPLES:
;	Calculate the total number of rows in a set of FITS files.
;	
;	IDL> file = file_search()
;	IDL> print, nrows_in_fits(file,/cum)
;	              80208523
;	
; PROCEDURES CALLED:
;
; REVISION HISTORY:
;   2018-Apr-25  Written by C. M. Carroll (Dartmouth)
;-----------------------------------------------------------------------------------------
FUNCTION nrows_in_fits, files, $
                        CUM = cum


rows = lon64arr(n_elements(files))

if (typename(files) eq 'STRING') then files = file_search(files);; enables call with "*" wildcard
for i = 0,n_elements(files)-1 do begin
	fits_open,files[i],fcb						                ;; opens FITS Control Block
	rows[i] = fcb.axis[1,1]		                                ;; grab number of rows               
	fits_close,fcb
endfor

if keyword_set(cum) then rows = total(rows)

return, rows


END




