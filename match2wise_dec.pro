PRO match2wise_dec, data, $
					prefix, $
					col, $
					COMPRESS = compress


;; example prefix, declination column (COLUMNS STARTS AT 1)
;; 'sdss-dr12-cat-part', 4
;; 'wise-allwise-cat-part', 3
;; 'ukidss-las10-cat-part', 2
;; 'unwise-dr10sed-cat-part', 2
;; 'xdqso-z-cat-part', 8
;; 'galex-dr6-cat-part', 6
;; 'qso-zsupp-cat-part', 4

;tic
print, "Begin processing"
;; declination split of AllWISE catalogs
declo = [-90.000000d,-74.240000d,-67.927300d,-62.944400d,-58.612800d,-54.775900d,-51.267600d,-47.958100d,-44.807200d,-41.784400d,-38.860700d,-36.029800d,-33.257200d,-30.551400d,-27.896500d,-25.250300d,-22.629900d,-20.043100d,-17.452900d,-14.862900d,-12.277900d,-9.684500d,-7.083500d,-4.476500d,-1.861900d,0.746200d,3.357000d,5.987600d,8.619900d,11.275200d,13.943800d,16.641700d,19.362100d,22.111600d,24.906400d,27.733200d,30.605700d,33.546100d,36.548700d,39.645300d,42.841900d,46.153000d,49.606100d,53.260800d,57.180600d,61.619500d,66.823700d,73.620200d]
dechi = [declo[1:-1],90.000000d]

;; output SDSS file names
ndecbins = n_elements(dechi)	;; number of declination bins
;; output str
;str = 'sdss-dr12-cat-part'+string(indgen(ndecbins,start=1),format='(i02)')+'.fits'
str = prefix+string(indgen(ndecbins,start=1),format='(i02)')+'.fits'

;; batch full file in rows--cannot handle the full dataset
fits_open,data,fcb  								;; open FITS file
nrows = total(fcb.axis[1,*],/PRESERVE_TYPE)         ;; pull number of rows in data
fits_close,fcb										;; close FITS file
rowbatch = 5000000L             		            ;; number of rows in a batch
nbatches = ceil(nrows/(rowbatch*1.))	            ;; number of batches of rows

;; loop over the rows
for i = 0L,nbatches-1 do begin
	rows = [i*rowbatch:(i+1)*rowbatch-1 < (nrows-1)]
	print, "Rows: "+strtrim(rows[0],2)+' : '+strtrim(rows[-1],2)
	;print, "Pulling declination"
	;; pull only declination
	r = mrdfits(data,1,rows=rows,columns=col,/SILENT)		;; read in declination, column=4
	dec = r.(0)
	;; loop over declination and grab indices within dec range
	for j = 0,ndecbins-1 do begin
		print, strtrim(declo[j],2) + " < dec <= " + strtrim(dechi[j],2)
		irow = where(dec gt declo[j] and dec le dechi[j],rowlen)
		if (rowlen eq 0) then continue
		r = mrdfits(data,1,rows=rows[irow],/SILENT)		    ;; pull all columns at these rows
		re = execute('mwrfits,r,str[j],/SILENT')		    ;; write to file
	endfor
endfor
;; the above loop appends to the FITS file for each batch of rows
;; it is then necessary to loop over the extensions and conatenate

;; loop over each file
file = file_search(prefix+'*')
totrows = 0L											;; total number of rows in all combined files
for j = 0,n_elements(file)-1 do begin
	print, 'Concatenating: '+file[j]
	fits_open,file[j],fcb								;; open FITS file
	n_ext = fcb.nextend									;; grab the number of extensions
	totrows += total(fcb.axis[1,*],/PRESERVE_TYPE)
	fits_close,fcb										;; close FITS file
	var = 'r'+strtrim(indgen(n_ext,start=1),2)			;; structure name array
	for k = 0,n_ext-1 do re = execute(var[k]+' = mrdfits(file[j],k+1,/SILENT)')	;; loop over all extensions and pull 
	var_str = strjoin(var,',')							;; full output name array
	re = execute('r_full = ['+var_str+']')				;; concatenate all data into one structure
	re = execute('mwrfits,r_full,file[j],/SILENT,/CREATE')	;; write FITS file with CREATE keyword to overwrite and not append
endfor

print, "Total number of rows: Start="+strtrim(nrows,2)+"    End="+strtrim(totrows,2)
;toc

if keyword_set(compress) then spawn,'for file in *part*.fits; do gzip "$file"; done'


end



