;
;+
;Description : Detection of three dimensional magnetic null points
;Author : Satyam Agarwal, Senior Research Fellow, Udaipur Solar Observatory
;-
;

;----------------------------------------------------------
; Initial file setup
;----------------------------------------------------------

file = 'bnfff_02_02_2014_h0400_vectorb_400_250_250.sav'		; Specify the path of .sav file
restore, file, /v
box_size = size(bvx)
nx=box_size(1)
ny=box_size(2)
nz=box_size(3)
 
;---------------------------------
; Initial variable declarations
;---------------------------------

file = 'nulls.txt'						; File to store location of null points
openw, ounit, file, /get_lun, width=200			; Open data file
mag  = sqrt(bvx*bvx+bvy*bvy+bvz*bvz)				; Magnitude of magnetic field vector
temp_mag = mag							; Dummy variable assignment

read, ch, prompt = 'How many null points would you like to test per surface along height direction (e.g. 1, 2, 3 etc.) : '
;or one can directly specify 
ch = 10

b_min = dblarr(nz,ch)
b_max = b_min
loc_x = lonarr(nz,ch)

;--------------------------------------------------------------------------------------------------
; Identify locations of minimum magnetic field strengths
;--------------------------------------------------------------------------------------------------

for jj = 0 , ch - 1 do begin

	for ii = 0 , nz - 1 do begin
		
		check = where(temp_mag eq min(temp_mag(*,*,ii)))
		if (n_elements(check) gt 1) then begin	; This is because multiple locations may have the same value
		b_min(ii,jj) = temp_mag(check(0))
		endif else begin		
		b_min(ii,jj) = min(temp_mag(*,*,ii))
		endelse
		b_max(ii,jj) = max(temp_mag(*,*,ii))		; Identify maximum of magnetic field for every z = const. surface
		loc_x(ii,jj) = check(0)			; Store the pixel with minimum value
		temp_mag(check) = !values.f_nan		; Assign that location NaN after identification

	endfor

loc_ind = array_indices(temp_mag, loc_x)			; Indices of identified locations


;--------------------------------------------------------------------------------------------------
; Check if identified locations are null points
;--------------------------------------------------------------------------------------------------


temp_count1 = 0						; To count the number of detected 3D nulls
temp = nz*ch							; Total number of voxels to be checked
data_store = dblarr(3,3,3,3,temp)				; Number of voxels around null location in x, y and z directions (3,3,3) for each component (fourth index)
temp_iso = intarr(temp)
temp_numb = temp_iso

;--------------------------------------------------------------------------------------------------

for i = 0 , temp - 1 do begin
	if ((loc_ind(0,i) lt nx-1 and loc_ind(0,i) gt 0) and (loc_ind(1,i) lt ny-1 and loc_ind(1,i) gt 0) and (loc_ind(2,i) lt nz-1 and loc_ind(2,i) gt 0)) then begin ; To avoid boundary voxels
		for j = 0 , 2 do begin   
			for k = 0 , 2 do begin
				for l = 0 , 2 do begin
					data_store(j,k,l,0,i)  = bvx(loc_ind(0,i)-(1-j),loc_ind(1,i)-(1-k),loc_ind(2,i)-(1-l))
					data_store(j,k,l,1,i)  = bvy(loc_ind(0,i)-(1-j),loc_ind(1,i)-(1-k),loc_ind(2,i)-(1-l))
					data_store(j,k,l,2,i)  = bvz(loc_ind(0,i)-(1-j),loc_ind(1,i)-(1-k),loc_ind(2,i)-(1-l))
			        endfor
		        endfor
	        endfor 
		
		temp_count = 0
		
		if data_store(0,1,1,0,i)*data_store(2,1,1,0,i) lt 0 then begin 
		temp_count = temp_count + 1
		endif

		if data_store(1,0,1,1,i)*data_store(1,2,1,1,i) lt 0 then begin
		temp_count = temp_count + 1  
   		endif
	
		if data_store(1,1,0,2,i)*data_store(1,1,2,2,i) lt 0 then begin
		temp_count = temp_count + 1
		endif
   
		if (temp_count gt 2) then begin
		temp_count1 = temp_count1 + 1
		temp_iso(temp_count1 - 1) = i			; Gives the ith number at which null is detected
   		temp_numb(temp_count1 - 1) = temp_count	; Redundant
       	endif

        endif
endfor

;--------------------------------------------------------------------------------------------------
; Rearrange
;--------------------------------------------------------------------------------------------------

temp_x1 = where(temp_iso ne 0)
temp_iso_new = temp_iso(temp_x1)
loc_ind = loc_ind(*,temp_iso_new)				; Indices of the detected magnetic null points

;--------------------------------------------------------------------------------------------------
; In normalized coordinates with type of null (1,2,3)
;--------------------------------------------------------------------------------------------------

loc_ind = double(loc_ind)
s_length = 1.0/double(nx)					; Assuming nx is the largest length in computational box
loc_ind_new = loc_ind*s_length				; Locations in normalized coordinates
if(temp_count1 eq 0) then begin				; If there are no nulls in the box
print, 'no null found'
endif

;--------------------------------------------------------------------------------------------------
; Save null point locations
;--------------------------------------------------------------------------------------------------

for i = 0, temp_count1 - 1 do begin

	printf, ounit, ''
	printf, ounit, loc_ind(0,i), loc_ind(1,i), loc_ind(2,i), loc_ind_new(0,i), loc_ind_new(1,i), loc_ind_new(2,i)
	printf, ounit, ''

endfor

endfor

free_lun, ounit						; Close data file

stop
end
