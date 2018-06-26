;-----------------------------------------------------------------------------------------
; NAME:                                                                       IDL Function
;	cat_match
;   
; PURPOSE:
;   Match and combine two catalogs stored in IDL structure format. Catalogs are matched 
;   by INNER/OUTER/LEFT join, and combined within a specified angular separation. The
;   special SUPPLEMENT join can be used to add additional fields to cat1 (see comments).
;
; CALLING SEQUENCE:
;   cc = cat_match( cat1, cat2, label1, label2, ang, [, JOIN= ] )
; INPUTS:
;	cat1            - IDL structure containing the first catalog to join.
;	cat2            - IDL structure containing the second catalog to join.
;   label1          - String of tag label for catalog 1.
;   label2          - String of tag label for catalog 2.
;	ang             - Scalar of angular separation for matching in arcseconds.
;
; OPTIONAL INPUTS:
;   JOIN            - String containing the join type, either 'INNER', 'OUTER', or 'LEFT'.
;   /TAGS_ONLY      - Keyword to signal appending of tags only; no data to be added.
;
; OUTPUTS:
;   cc              - Combined catalogs.
;
; OPTIONAL OUTPUTS:
;  
; COMMENTS:
;   The two input catalogs must contain positions of RA/Dec given by the label tags.
;   For example, matching WISE to SDSS,s the data must follow the format:
;       cat1 (SDSS); cat1.RA_SDSS, cat1.DEC_SDSS; label1 = '_SDSS'
;       cat2 (WISE); cat2.RA_WISE, cat2.DEC_WISE; label2 = '_WISE'
;
;   For an OUTER join, the positions of matched and unmatched sources are combined into
;   two new columns, 'RA' and 'DEC', without a following label. This is done so following
;   calls to CAT_MATCH() will not skip sources supplemental to the original catalog. 
;   For example, matching SDSS to XDQSOz as an outer join will supplement non-matched 
;   sources to the sample, and create new position columns, 'RA' and 'DEC'. Further 
;   matching this new sample to WISE can be matched to 'RA' and 'DEC', and not 'RA_SDSS' 
;   and 'DEC_SDSS', which would skip the XDQSOz sources supplemented in the first call
;   to CAT_MATCH(), where RA_SDSS=-9999 and DEC_SDSS=-9999. Given the addition of 'RA' 
;   and 'DEC', only one OUTER join is allowed for multiple calls to CAT_MATCH().
;
;   The comments within SPHEREMATCH() suggest that the first input array be the largest
;   to minimize computational time. I've taken this into consideration here and the 
;   input size of both catalogs are compared before the call to SPHEREMATCH(). The most
;   efficient call is then preformed, so there is no need to alter your input catalogs.
;
;   By default, cat2 is the catalog matched to cat1, and the 'SEPARATION' label will 
;   be constructed from label2.
;
;   The SUPPLEMENT join can be used when cat1 and cat2 have identical fields except for 
;   additional fields appended to cat2.
;
; EXAMPLES:
;   
; PROCEDURES CALLED:
;	EXCLUDE.PRO
;
; REVISION HISTORY:
;   2017-May-22  Written by Christopher M. Carroll (Dartmouth)
;-----------------------------------------------------------------------------------------
FUNCTION cat_match, cat1, $
                    cat2, $
                    label1, $
                    label2, $
                    ang, $
		            JOIN = join, $
		            TAGS_ONLY = tags_only


;; ensure join is set and uppercase
if keyword_set(join) then join = strupcase(join) else join = 'NONE'

;; new tag label for separation distance of calls to SPHEREMATCH()
sep_label = 'SEPARATION_'+label2
;; length of catalogs
c1len = n_elements(cat1)
c2len = n_elements(cat2)

;; call SPHEREMATCH() with largest catalog first
if (c1len ge c2len) then re = execute('spherematch,cat1.RA'+label1+',cat1.DEC'+label1+',cat2.RA'+label2+',cat2.DEC'+label2+',ang/3600.,ic1m,ic2m,sep') else $
                         re = execute('spherematch,cat2.RA'+label2+',cat2.DEC'+label2+',cat1.RA'+label1+',cat1.DEC'+label1+',ang/3600.,ic2m,ic1m,sep')
;; number of matches between both catalogs
if (total(ic1m) eq -1) then matchlen = 0 else $
                            matchlen = n_elements(ic1m)

case join of
	'INNER': begin
        ;; no matches on inner join
        if (matchlen eq 0) then begin
            print, 'WARNING: NO MATCHES FOR INNER JOIN'
            cc = !NULL
        endif
        ;; use first source of each catalog to combine catalog tags
        cc = struct_addtags(cat1[0],cat2[0])
        ;; clear the values from the tag combine
        for t = 0,n_tags(cc)-1 do if (typename(cc.(t)) eq 'STRING') then cc.(t) = '' else $
                                                                         cc.(t) = -9999.
        ;; add default separation tag
        struct_add_field,cc,sep_label,-9999.		 	        
        cc = replicate(cc,matchlen)
        ;; add data from each catalog
        for t = 0,n_tags(cat1)-1 do cc.(t) = cat1[ic1m].(t)
        for t = 0,n_tags(cat2)-1 do cc.(n_tags(cat1)+t) = cat2[ic2m].(t)
        ;; add angular separation distance
        re = execute('cc.'+sep_label+' = sep')
    end
	'OUTER': begin
        ;; use first source of each catalog to combine catalog tags
        cc = struct_addtags(cat1[0],cat2[0])
        ;; clear the values from the tag combine
        for t = 0,n_tags(cc)-1 do if (typename(r.(t)) eq 'STRING') then cc.(t) = '' else $
                                                                        cc.(t) = -9999.
        ;; add default separation, RA, DEC tags
        struct_add_field,cc,sep_label,-9999.
        struct_add_field,cc,'RA',-9999.
        struct_add_field,cc,'DEC',-9999.
        ;; check if keyword set to append tags and not data
        if keyword_set(tags_only) then begin
            cc = replicate(cc,c1len)
            for t = 0,n_tags(cat1)-1 do cc[0:c1len-1].(t) = cat1.(t)                ;; retain catalog 1 data
            re = execute('cc[0:c1len-1].ra = cc[0:c1len-1].RA'+label1)
            re = execute('cc[0:c1len-1].dec = cc[0:c1len-1].DEC'+label1)
            break
        endif
        cc = replicate(cc,c1len+c2len-matchlen)
        ;; if no matches...
        if (matchlen eq 0) then begin
            for t = 0,n_tags(cat1)-1 do cc[0:c1len-1].(t) = cat1.(t)                ;; add catalog 1 data
            re = execute('cc[0:c1len-1].ra = cc[0:c1len-1].RA'+label1)
            re = execute('cc[0:c1len-1].dec = cc[0:c1len-1].DEC'+label1)
            for t = 0,n_tags(cat2)-1 do cc[c1len:-1].(n_tags(cat1)+t) = cat2.(t)    ;; add catalog 2 data
            re = execute('cc[c1len:-1].ra = cc[c1len:-1].RA'+label2)
            re = execute('cc[c1len:-1].dec = cc[c1len:-1].DEC'+label2)
        ;; if matches... 
        endif else begin
            for t = 0,n_tags(cat1)-1 do cc[ic1m].(t) = cat1[ic1m].(t)               ;; add matched catalog 1 data
            for t = 0,n_tags(cat2)-1 do cc[ic1m].(n_tags(cat1)+t) = cat2[ic2m].(t)  ;; add matched catalog 2 data
            re = execute('cc[ic1m].'+sep_label+' = sep')
            re = execute('cc[ic1m].ra = cc[ic1m].RA'+label1)
            re = execute('cc[ic1m].dec = cc[ic1m].DEC'+label1)
            ;; add remaining catalog 1 data to cc
            if (c1len-matchlen gt 0) then begin
                ic1_remain = exclude(cat1,ic1m)
                for t = 0,n_tags(cat1)-1 do cc[ic1_remain].(t) = cat1[ic1_remain].(t)
                re = execute('cc[ic1_remain].ra = cc[ic1_remain].RA'+label1)
                re = execute('cc[ic1_remain].dec = cc[ic1_remain].DEC'+label1)
            endif
            ;; add remaining catalog 2 data to cc
            if (c2len-matchlen gt 0) then begin
                ic2_remain = exclude(cat2,ic2m)
                for t = 0,n_tags(cat2)-1 do cc[c1len:-1].(n_tags(cat1)+t) = cat2[ic2_remain].(t)
                re = execute('cc[c1len:-1].ra = cc[c1len:-1].RA'+label2)
                re = execute('cc[c1len:-1].dec = cc[c1len:-1].DEC'+label2)
            endif
        endelse
    end
	'LEFT': begin
        ;; use first source of each catalog to combine catalog tags
        cc = struct_addtags(cat1[0],cat2[0])
        ;; clear the values from the tag combine
        for t = 0,n_tags(cc)-1 do if (typename(cc.(t)) eq 'STRING') then cc.(t) = '' else $
                                                                         cc.(t) = -9999.
        ;; add default separation tag
        struct_add_field,cc,sep_label,-9999.
        cc = replicate(cc,c1len)
        ;; add all catalog 1 data to cc
        for t = 0,n_tags(cat1)-1 do cc.(t) = cat1.(t)
        ;; add matched catalog 2 data
        if (matchlen gt 0) then begin
            for t = 0,n_tags(cat2)-1 do cc[ic1m].(n_tags(cat1)+t) = cat2[ic2m].(t)
            re = execute('cc[ic1m].'+sep_label+' = sep')
        endif
    end
	'SUPPLEMENT': begin
	    ;; use tags from second catalog
	    cc = cat2[0] 
        ;; clear the values from the tag
        for t = 0,n_tags(cc)-1 do if (typename(cc.(t)) eq 'STRING') then cc.(t) = '' else $
                                                                         cc.(t) = -9999.
        ;; check if keyword set to append tags and not data
        if keyword_set(tags_only) then begin
            cc = replicate(cc,c1len)
            for t = 0,n_tags(cat1)-1 do cc[0:c1len-1].(t) = cat1.(t)                ;; retain catalog 1 data
            break
        endif
        cc = replicate(cc,c1len+c2len-matchlen)
        ;; if no matches...
        if (matchlen eq 0) then begin
            for t = 0,n_tags(cat1)-1 do cc[0:c1len-1].(t) = cat1.(t)                ;; add catalog 1 data
            for t = 0,n_tags(cat2)-1 do cc[c1len:-1].(n_tags(cat1)+t) = cat2.(t)    ;; add catalog 2 data
        ;; if matches... 
        endif else begin
            for t = 0,n_tags(cat1)-1 do cc[ic1m].(t) = cat1[ic1m].(t)                               ;; add matched catalog 1 data
            for t = 0,n_tags(cat2)-n_tags(cat1)-1 do cc[ic1m].(n_tags(cat1)+t) = cat2[ic2m].(t)     ;; add matched catalog 2 data
            ;; add remaining catalog 1 data to cc
            if (c1len-matchlen gt 0) then begin
                ic1_remain = exclude(cat1,ic1m)
                for t = 0,n_tags(cat1)-1 do cc[ic1_remain].(t) = cat1[ic1_remain].(t)
            endif
            ;; add remaining catalog 2 data to cc
            if (c2len-matchlen gt 0) then begin
                ic2_remain = exclude(cat2,ic2m)
                for t = 0,n_tags(cat2)-1 do cc[c1len:-1].(t) = cat2[ic2_remain].(t)
            endif
        endelse
	end
	else: begin
	        ;; what are you doing?
			print, 'NO JOIN TYPE SPECIFIED'
			cc = !NULL
		  end
endcase

return, cc


END


