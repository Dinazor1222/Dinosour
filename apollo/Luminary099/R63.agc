# Copyright:	Public domain.
# Filename:	R63.agc
# Purpose: 	Part of the source code for Luminary 1A build 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	338-341
# Mod history:	2009-05-16 RSB	Adapted from the corresponding 
#				Luminary131 file, using page 
#				images from Luminary 1A.
#
# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the MIT Museum.  The digitization
# was performed by Paul Fjeld, and arranged for by Deborah Douglas of
# the Museum.  Many thanks to both.  The images (with suitable reduction
# in storage size and consequent reduction in image quality as well) are
# available online at www.ibiblio.org/apollo.  If for some reason you
# find that the images are illegible, contact me at info@sandroid.org
# about getting access to the (much) higher-quality images which Paul
# actually created.
#
# Notations on the hardcopy document read, in part:
#
#	Assemble revision 001 of AGC program LMY99 by NASA 2021112-61
#	16:27 JULY 14, 1969 

# Page 338
# SUBROUTINE NAME:	V89CALL
# MOD NO:	0			DATE:		9 JAN 1968
# MOD BY:	DIGITAL DEVEL GROUP	LOG SECTION:	R63
#
# FUNCTIONAL DESCRIPTION:
#
# CALLED BY VERB 89 ENTER DURING P00.  PRIO 10 USED.  CALCULATES AND
# DISPLAYS FINAL FDAI BALL ANGLES TO POINT LM +X OR +Z AXIS AT CSM.
#
# 1. KEY IN V 89 E ONLY IF IN PROG 00.  IF NOT IN P00, OPERATOR ERROR AND
# EXIT R63, OTHERWISE CONTINUE.
#
# 2. IF IN P00, DO IMU STATUS CHECK ROUTINE (R02BOTH).  IF IMU ON AND ITS
# ORIENTATION KNOWN TO LGC, CONTINUE.
#
# 3. FLASH DISPLAY V 04 N 06.  R2 INDICATES WHICH SPACECRAFT AXIS IS TO
# BE POINTED AT CSM.  INITIAL CHOICE IS PREFERRED (+Z) AXIS (R2=1).
# ASTRONAUT CAN CHANGE TO (+X) AXIS (R2 NOT =1) BY V 22 E 2 E.  CONTINUE
# AFTER KEYING IN PROCEED.
#
# 4. BOTH VEHICLE STATE VECTORS UPDATED BY CONIC EQS.
#
# 5. HALF MAGNITUDE UNIT LOS VECTOR (IN STABLE MEMBER COORDINATES) AND
# HALF MAGNITUDE UNIT SPACECRAFT AXIS VECTOR (IN BODY COORDINATES)
# PREPARED FOR VECPOINT.
#
# 6. GIMBAL ANGLES FROM VECPOINT TRANSFORMED INTO FDAI BALL ANGLES BY
# BALLANGS.  FLASH DISPLAY V 06 N 18 AND AWAIT RESPONSE.
#
# 7 	RECYCLE -- RETURN TO STEP 4.
#	TERMINATE -- EXIT R63
#	PROCEED -- RESET 3AXISFLAG AND CALL R60LEM FOR ATTITUDE MANEUVER.
#
# CALLING SEQUENCE:	V 89 E.
#
# SUBROUTINES CALLED:	CHECKP00H, R02BOTH, GOXDSPF, CSMCONIC, LEMCONIC,
#			VECPOINT, BALLANGS, R60LEM.
#
# NORMAL EXIT MODES: 	TC ENDEXT
#
# ALARMS:	1. OPERATOR ERROR IF NOT IN P00.
#		2. PROGRAM ALARM IF IMU IS OFF.
#		3. PROGRAM ALARM IF IMU ORIENTATION IS UNKNOWN.
#
# OUTPUT:	NONE
#
# ERASABLE INITIALIZATION REQUIRED:  NONE
#
# DEBRIS:	OPTION1, +1, TDEC1, PCINTVSM, SCAXIS, CPHI, CTHETA, CPSI,
# Page 339
#		3AXISFLAG.

		EBANK=	RONE
		BANK	32
		SETLOC	BAWLANGS
		BANK
		
		COUNT*	$$/R63
V89CALL		TC	BANKCALL	# IMU STATUS CHECK.  RETURNS IF ORIENTATION
		CADR	R02BOTH		# KNOWN.  ALARMS IF NOT.
		CAF	THREE		# ALLOW ASTRONAUT TO SELECT DESIRED
		TS	OPTIONX		# TRACKING ATTITUDE AXIS.
		CAF	ONE
		TS	OPTIONX  +1
		CAF	VB04N12		# V 04 N 12.
		TC	BANKCALL
		CADR	GOFLASH
		TC	ENDEXT		# TERMINATE
		TC 	+2		# PROCEED
		TC	-5		# DATA IN.  OPTION1+1 = 1 FOR Z AXIS
V89RECL		TC	INTPRET		#			2 FOR X AXIS
		RTB	DAD
			LOADTIME	# READ PRESENT TIME
			DP1MIN
		STORE	TSTART82	# SAVE TIME FOR LEMCONIC CALL
		STCALL	TDEC1		# STORE TIME FOR CSMCONIC CALL
			CSMCONIC	# CSM STATE VECTOR UPDATE
		VLOAD			# CSMCONIC LEFT R VECTOR IN RATT
			RATT
		STODL	RONE		# SAVE FOR LINE OF SIGHT (LOS) COMPUTATION
			TSTART82
		STCALL	TDEC1		# STORE TIME FOR LEMCONIC CALL
			LEMCONIC	# LEM STATE VECTOR UPDATE
		VLOAD	VSU		# CSM POSITION -- LEM POSITION -- LOS
			RONE		# LOS VECTOR LEFT IN MPAC
			RATT
		MXV	RTB		# (REFSMAT X LOS).  TRANSFORMS LOS FROM
			REFSMMAT	# REFERENCE COORD TO STAB MEMB COORD.
			NORMUNIT
		STORE	POINTVSM	# STORE LOS FOR VECPOINT CALCULATION
		EXIT
		CS	OPTIONX +1	# 1 FOR Z AXIS.  2 FOR X AXIS.
		AD	ONE
		EXTEND
		BZF	ALINEZ
ALINEX		TC	INTPRET		# X AXIS ALIGNMENT
		VLOAD
			UNITX		# READ (.5, 0, 0)
# Page 340
V89CALL1	STCALL	SCAXIS		# STORE SELECTED ALIGNMENT AXIS
			VECPOINT	# PUTS DESIRED GIM ANG (OG,IG,MG) IN TMPAC
		STORE	CPHI		# STOR GIMBAL ANGLES FOR BALLANGS CALL
		EXIT
		TC	BANKCALL
		CADR	BALLANGS	# PUTS DESIRED BALL ANGLE IN FDAIX,Y,Z
		CAF	VB06N18		# V 06 N 18
		TC	BANKCALL	# NOUN 18 REFERS TO FDAIX,Y,Z
		CADR	GOFLASH
		TC	ENDEXT		# TERMINATE
		TC	+2		# PROCEED
		TC	V89RECL		# RECYCLE
		TC	DOWNFLAG	# RESET 3 AXIS FLAG
		ADRES	3AXISFLG	# RESET BIT6 FLAG WORD 5
		TC	BANKCALL	# PERFORMS LEM MANEUVER TO ALIGN SELECTED
		CADR	R60LEM		# SPACECRAFT AXIS TO CSM.
		TCF	ENDEXT		# TERMINATE R63
		
ALINEZ		TC	INTPRET		# Z AXIS ALIGNMENT
		VLOAD	GOTO
			UNITZ		# READ (0, 0, .5)
			V89CALL1
			
VB04N12		VN	412
VB06N18		VN	0618
# Page 341
DP1MIN		2DEC	6000

