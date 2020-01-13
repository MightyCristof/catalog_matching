PRO match_samp2xcat, data
;; match "data.fits" to xMatch catalog and produce output file

dir_xcat = '/Users/ccarroll/Research/surveys/x-Match/SDSSxWISE/'
join = 'LEFT'

col_dec = where(strmatch(tag_names(mrdfits(data,1)),'*DEC*'),ct)
if (ct eq 0) then begin
    print, 'NEED DECLINATION'
    stop
endif

file_mkdir,'sample_files'
pushd,'sample_files'

match2wise_dec,'../'+data,'data-part',col_dec+1
data_samp = file_search('data-part*')
data_xcat = file_search(dir_xcat+'*')

;; sky sections by 'parts'
part_samp = (strsplit(data_samp,'-./',/extract)).toArray()
part_samp = part_samp[where(strmatch(part_samp,'*part*'))]
part_xcat = (strsplit(data_xcat,'-./',/extract)).toArray()
part_xcat = part_xcat[where(strmatch(part_xcat,'*part*'))]

match,part_xcat,part_samp,ixcat,isamp
data_xcat = data_xcat[ixcat]
data_samp = data_samp[isamp]

for i = 0,n_elements(data_samp)-1 do begin
    
    xcat = mrdfits(data_xcat[i],1)
    samp = mrdfits(data_samp[i],1)
    tags = tag_names(samp)
    sffx = strsplit(tags[where(strmatch(tags,'*DEC*'))],'DEC',/regex,/extract)
    
    r = cat_match(samp,xcat,sffx[0],'',12.,join=join)
    mwrfits,r,'xmatch-'+data_samp[i]
endfor

data_fit = file_search('xmatch-*')
data = mrdfits(data_fit[0],1)
for i = 1,n_elements(data_fit)-1 do data = [data,mrdfits(data_fit[i],1)]
popd

mwrfits,data,'sample_xmatch.fits',/create


END







