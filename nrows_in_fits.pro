;-----------------------------------------------------------------------------------------
; NAME:                                                                       IDL Function
;   NROWS_IN_FITS
;   
; PURPOSE:
;   Return the number of rows in a given FITS file, or array of FITS files.
;   
; CALLING SEQUENCE:
;   nrows_in_fits, file, [/cum]
;	
; INPUTS:
;   file			- Input string or string array of FITS files.
;   
; OPTIONAL INPUTS:
;   cum				- Cumulative sum for array of input FITS files.
;   
; OUTPUTS:
;   nrows			- Number of rows in FITS file.
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
FUNCTION nrows_in_fits, file, $
						CUM = cum


sz = size(file,/dim)							;; check input array size; single string = 0
if (sz eq 0) then cum = 1						;; for single string, automatically cumulative
if keyword_set(cum) then nrows = long64(0) else $
                         nrows = lon64arr(sz)		;; if CUM not set, output array of rows

if (typename(file) eq 'STRING') then file = file_search(file)	;; enables call with "*" wildcard
for i = 0,n_elements(file)-1 do begin
	fits_open,file[i],fcb						;; opens FITS Control Block
	if keyword_set(cum) then nrows += fcb.axis[1,1] else $		;; grab number of rows
	                         nrows[i] = fcb.axis[1,1]
	fits_close,fcb
endfor

return, nrows


END




