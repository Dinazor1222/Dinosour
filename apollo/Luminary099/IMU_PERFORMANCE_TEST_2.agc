# Copyright:	Public domain.
# Filename:	IMU_PERFORMANCE_TEST_2.agc
# Purpose: 	Part of the source code for Luminary 1A build 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	373-381
# Mod history:	2009-05-17 RSB	Adapted from the corresponding 
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

# Page 373
# NAME --	IMU PERFORMANCE TESTS 2
#
# DATE --	MARCH 20, 1967
#
# BY --		SYSTEM TEST GROUP 864-6900 EXT. 1274
#
# MODNO. --	ZERO
#
# FUNCTIONAL DESCRIPTION
#
# POSITIONING ROUTINES FOR THE IMU PERFORMANCE TESTS AS WELL AS SOME OF
# THE TESTS THEMSELVES.  FOR A DESCRIPTION OF THESE SUBROUTINES AND THE
# OPERATING PROCEDURES (TYPICALLY) SEE STG MEMO 685.  THEORETICAL REF. E-1973

		BANK	33
		SETLOC	IMU2
		BANK
		EBANK=	POSITON
		COUNT*	$$/P07
		
REDO		TC	NEWMODEX
		MM	07
		
GEOIMUTT	TC	IMUZERR
IMUBACK		CA	ZERO
		TS	NDXCTR
		TS	TORQNDX
		TS	TORQNDX +1
		TS	OVFLOWCK
NBPOSPL		CA	DEC17
		TS	ZERONDX
		CA	XNBADR
		TC	ZEROING
		CA	HALF
		TS	XNB
GUESS		TC	INTPRET
LATAZCHK	DLOAD	SL2
			LATITUDE
		STODL	DSPTEM1 +1
			AZIMUTH
		RTB	EXIT
			1STO2S
		XCH	MPAC
		TS	DSPTEM1
		CAF	VN0641
		TC	BANKCALL
		CADR	GOFLASH
		TC	ENDTEST1
		TC	+2
		TC	-5
# Page 374
		TC	INTPRET
		SLOAD	RTB
			DSPTEM1
			CDULOGIC
		STORE	AZIMUTH
		SLOAD	SR2
			DSPTEM1 +1
		STORE	LATITUDE
		COS	DCOMP
		SL1
		STODL	WANGI
			LATITUDE
		SIN	SL1
		STODL	WANGO
			AZIMUTH
		PUSH	SIN
		STORE	YNB 	+2
		STODL	ZNB 	+4
		COS
		STORE	YNB	+4
		DCOMP
POSGMBL		STCALL	ZNB 	+2
			CALCGA
		EXIT
		TC	BANKCALL
		CADR	IMUCOARS
		CAF	BIT14		# IF BIT14 SET, GIMBAL LOCK
		MASK	FLAGWRD3
		EXTEND
		BZF	+2
		INCR	NDXCTR		# +1 IF IN GIMBAL LOCK, OTHERWISE 0
		TC	DOWNFLAG
		ADRES	GLOKFAIL	# RESET GIMBAL LOCK FLAG
		TC	IMUSLLLG
		CCS	NDXCTR		# IF ONE GO AND DO A PIPA TEST ONLY
		TC	PIPACHK		# ALIGN AND MEASURE VERTICAL PIPA RATE
		TC	FINIMUDD
		EXTEND
		DCA	PERFDLAY
		TC	LONGCALL	# DELAY WHILE SUSPENSION STABILIZES
		EBANK=	POSITON
		2CADR	GOESTIMS
		
		CA	ESTICADR
		TC	JOBSLEEP
GOESTIMS	CA	ESTICADR
		TC	JOBWAKE
		TC	TASKOVER
ESTICADR	CADR	ESTIMS
TORQUE		CA	ZERO
# Page 375
		TS	DSPTEM2
		CA	DRIFTI
		TS	DSPTEM2 +1
		INDEX	POSITON
		TS	SOUTHDR -1
		TC	SHOW
		
PIPACHK		INDEX	NDXCTR		# PIPA TEST
		TC	+1
		TC	EARTHR*
		CA	DEC17		# ALLOW PIP COUNTER TO OVERFLOW 17 TIMES
		TS	DATAPL	+4	# IN THE ALLOTTED TIME INTERVAL
		CA	DEC58
		TS	LENGTHOT
		CA	ONE
		TS	RESULTCT
		CA	ZERO
		INDEX	PIPINDEX
		TS	PIPAX
		TS	DATAPL
		TC	CHECKG
		INHINT
		CAF	TWO
		TC	TWIDDLE
		EBANK=	XSM
		ADRES	PIPATASK
		TC	ENDOFJOB
		
PIPATASK	EXTEND
		DIM	LENGTHOT
		CA	LENGTHOT
		EXTEND
		BZMF	STARTPIP
		CAF	BIT10
		TC	TWIDDLE
		EBANK=	XSM
		ADRES	PIPATASK
STARTPIP	CAF	PRIO20
		TC	FINDVAC
		EBANK=	XSM
		2CADR	PIPJOBB
		
		TC	TASKOVER
		
PIPJOBB		INDEX	NDXCTR
		TC	+1
		TC	EARTHR*
		CA	LENGTHOT
# Page 376
		EXTEND
		BZMF	+2
		TC	ENDOFJOB
		
		CA	FIVE
		TS	RESULTCT
		TC	CHECKG
		CCS	DATAPL 	+1
		TC	+4
		TC	CCSHOLE
		CS	DATAPL	+4
		TS	DATAPL	+4
		EXTEND
		DCS	DATAPL
		DAS	DATAPL 	+4
		
		TC	INTPRET
		DLOAD	DSU
			DATAPL	+6
			DATAPL 	+2
		BPL	CALL
			AINGOTN
			OVERFFIX
AINGOTN		PDDL	DDV
			DATAPL 	+4
		DMPR	RTB
			DEC585		# DEC585 HAS BEEN REDEFINED FOR LEM
			SGNAGREE
		STORE	DSPTEM2
		EXIT
		CCS	NDXCTR
		TC	COAALIGN	# TAKE PLATFORM OUT OF GIMBAL LOCK
		TC	SHOW
VERTDRFT	CA	3990DEC		# ABOUT 1 HOUR VERTICAL DRIFT TEST
		TS	LENGTHOT
		INDEX	POSITON
		CS	SOUTHDR -2
		TS	DRIFTT
		CCS	PIPINDEX	# OFFSET PLATFORM TO MISS PIP DEAD-ZONES
		TCF	PON4		# Z-UP IN POS 4
PON2		CS	BIT5		# X-UP
		ADS	ERCOMP 	+2
		CA	BIT5
		ADS	ERCOMP 	+4
		TCF	PON
PON4		CS	BIT5
		ADS	ERCOMP	+2
		CA	BIT5
		ADS	ERCOMP
PON		TC	EARTHR*
# Page 377
		CA	ZERO		# ALLOW ONLY SOUTH GYRO EARTH RATE COMPENS
		TS	ERVECTOR
		TS	ERVECTOR +1
GUESS1		CAF	POSMAX
		TS	TORQNDX
		TS	TORQNDX +1
		CA	CDUX
		TS	LOSVEC
		TC	ESTIMS
VALMIS		CA	DRIFTO
		TS	DSPTEM2 +1
		CA	ZERO
		TS	DSPTEM2
		TC	SHOW
		
ENDTEST1	TC	DOWNFLAG
		ADRES	IMUSE
		CS	ZERO
		TC	NEWMODEA
		TC	ENDEXT
		
# Page 378
OVERFFIX	DAD	DAD
			DPPOSMAX
			ONEDPP
		RVQ
		
COAALIGN	EXTEND			# COARSE ALIGN SUBROUTINE
		QXCH	ZERONDX
		CA	ZERO
		TS	THETAD
		TS	THETAD +1
		TS	THETAD +2
		TC	BANKCALL
		CADR	IMUCOARS
ALIGNCOA	TC	BANKCALL
		CADR	IMUSTALL
		TC	SOMERR2
		TC	ZERONDX

IMUSLLLG	EXTEND
		QXCH	ZERONDX
		TC	ALIGNCOA
		
FINIMUDD	EXTEND
		QXCH	ZERONDX
		TC	BANKCALL
		CADR	IMUFINE
		TC	ALIGNCOA
		
IMUZERR		EXTEND
		QXCH	ZERONDX
		TC	BANKCALL
		CADR	IMUZERO
		TC	ALIGNCOA
		
CHECKG		EXTEND			# PIP PULSE CATCHING ROUTINE
		QXCH	QPLACE
		TC	+6
CHECKG1		RELINT
		CA	NEWJOB
		EXTEND
		BZMF	+6
		TC	CHANG1
		INHINT
		INDEX	PIPINDEX
		CS	PIPAX
		TS	ZERONDX
		INHINT
# Page 379
		INDEX	PIPINDEX
		CA	PIPAX
		AD	ZERONDX
		EXTEND
		BZF	CHECKG1
		INDEX	PIPINDEX
		CA	PIPAX
		INDEX	RESULTCT
		TS	DATAPL
		TC	FINETIME
		INDEX	RESULTCT
		TS	DATAPL +1
		INDEX	RESULTCT
		LXCH	DATAPL +2
		RELINT
ENDCHKG		TC	QPLACE

ZEROING		TS	L
		TCF	+2
ZEROING1	TS	ZERONDX
		CAF	ZERO
		INDEX	L
		TS	0
		INCR	L
		CCS	ZERONDX
		TCF	ZEROING1
		TC	Q

# Page 380
ERTHRVSE	DLOAD	PDDL
			SCHZEROS	# PD24 = (SIN             -COS     0)(OMEG/MS)
			LATITUDE
		COS	DCOMP
		PDDL	SIN
			LATITUDE
		VDEF	VXSC
			OMEG/MS
		STORE	ERVECTOR
		RTB
			LOADTIME
		STOVL	TMARK
			SCHZEROS
		STORE	ERCOMP
		RVQ
		
EARTHR		ITA	RTB
			S2
			LOADTIME
		STORE	TEMPTIME
		DSU	BPL
			TMARK
			ERTHR
		CALL
			OVERFFIX
ERTHR		SL	VXSC
			9D
			ERVECTOR
		MXV	VAD
			XSM
			ERCOMP
		STODL	ERCOMP
			TEMPTIME
		STORE	TMARK
		AXT,1	RTB
		ECADR	ERCOMP
			PULSEIMU
		GOTO
			S2
			
EARTHR*		EXTEND
		QXCH	QPLACES
		TC	INTPRET
		CALL
			EARTHR
		EXIT
		TC	IMUSLLLG
		TC	QPLACES
		
SHOW		EXTEND
# Page 381
		QXCH	QPLACE
SHOW1		CA	POSITON
		TS	DSPTEM2 +2
		CA	VB06N98
		TC	BANKCALL
		CADR	GOFLASH
		TC	ENDTEST1	# V34
		TC	QPLACE		# V33
		TCF	SHOW1
		
3990DEC		DEC	3990
VB06N98		VN	0698
VN0641		VN	0641
DEC17		=	ND1
DEC58		DEC	58
OGCPL		ECADR	OGC
1SECX		=	1SEC
XNBADR		GENADR	XNB
XSMADR		GENADR	XSM
		BLOCK	2
		COUNT*	$$/P07
FINETIME	INHINT			# RETURNS WITH INTERRUPT INHIBITED
		EXTEND
		READ	LOSCALAR
		TS	L
		EXTEND
		RXOR	LOSCALAR
		EXTEND
		BZF	+4
		EXTEND
		READ	LOSCALAR
		TS	L
	+4	CS	POSMAX
		AD	L
		EXTEND
		BZF	FINETIME +1
		EXTEND
		READ	HISCALAR
		TC Q
		
