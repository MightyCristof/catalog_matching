;-----------------------------------------------------------------------------------------
; NAME:                                                                       IDL Function
;   exclude
;
; PURPOSE:
;   Return the indices of an array, sans the indices passed to the function. Similar 
;   to a WHERE() call with the COMPLEMENT keyword set, but can be used when you already
;   have an array of indices (e.g., a call to MATCH).
;
; CALLING SEQUENCE:
;   not_ind = exclude( arr, ind )

; INPUTS:
;   arr             - Array from which the original indices where drawn.
;   ind             - Input array of indices you wish to exclude from arr.
;
; OPTIONAL INPUTS:
;   
; OUTPUTS:
;   not_ind         - The indices of arr which complement ind.
;
; OPTIONAL OUTPUTS:
;   
; COMMENTS:
;   
; EXAMPLES:
;   IDL> a = findgen(10)
;   IDL> ind = where(a mod 2. eq 0.)
;   IDL> not_ind = exclude(a,ind)
;   IDL> print, a[ind]
;             0.00000      2.00000      4.00000      6.00000      8.00000
;   IDL> print, a[not_ind]
;             1.00000      3.00000      5.00000      7.00000      9.00000
;
; PROCEDURES CALLED:
;   
; REVISION HISTORY:
;   2014-Dec-12  Written by Christopher M. Carroll (Dartmouth)
;-----------------------------------------------------------------------------------------
FUNCTION exclude, arr, $
                  ind


not_ind = lindgen(n_elements(arr))      ;; all indices in arr
remove, ind, not_ind                    ;; remove ind from arr

return, not_ind


END


