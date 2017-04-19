# Copyright:    Public domain.
# Filename:     RESTARTS_ROUTINE.agc
# Purpose:      Part of the source code for Comanche, build 055. It
#               is part of the source code for the Command Module's
#               (CM) Apollo Guidance Computer (AGC), Apollo 11.
# Assembler:    yaYUL
# Reference:    pp. 1414-1419
# Contact:      Ron Burkey <info@sandroid.org>
# Website:      http://www.ibiblio.org/apollo.
# Mod history:  2009-05-07 RSB	Adapted from Colossus249 file of the same
#				name, and page images. Corrected various 
#				typos in the transcription of program 
#				comments, and these should be back-ported  
#				to Colossus249.
#
# The contents of the "Comanche055" files, in general, are transcribed 
# from scanned documents. 
#
#       Assemble revision 055 of AGC program Comanche by NASA
#       2021113-051.  April 1, 1969.  
#
#       This AGC program shall also be referred to as Colossus 2A
#
#       Prepared by
#                       Massachusetts Institute of Technology
#                       75 Cambridge Parkway
#                       Cambridge, Massachusetts
#
#       under NASA contract NAS 9-4065.
#
# Refer directly to the online document mentioned above for further
# information.  Please report any errors to info@sandroid.org.

# Page 1414
		BANK	01
		SETLOC	RESTART
		BANK

		EBANK=	PHSNAME1	# GOPROG MUST SWITCH TO THIS EBANK

		COUNT	01/RSROU
		
RESTARTS	CA	MPAC +5		# GET GROUP NUMBER -1
		DOUBLE			# SAVE FOR INDEXING
		TS	TEMP2G

		CA	PHS2CADR	# SET UP EXIT IN CASE IT IS AN EVEN
		TS	TEMPSWCH	# TABLE PHASE

		CA	RTRNCADR	# TO SAVE TIME ASSUME IT WILL GET NEXT
		TS	GOLOC +2	# GROUP AFTER THIS

		CA	TEMPPHS
		MASK	OCT1400
		CCS	A		# IS IT A VARIABLE OR TABLE RESTART
		TCF	ITSAVAR		# IT'S A VARIABLE RESTART

GETPART2	CCS	TEMPPHS		# IS IT AN X.1 RESTART
		CCS	A
		TCF	ITSATBL		# NO, IT'S A TABLE RESTART

		CA	PRIO14		# IT IS AN X.1 RESTART, THEREFORE START
		TC	FINDVAC		# THE DISPLAY RESTART JOB
		EBANK=	LST1
		2CADR	INITDSP

		TC	RTRNCADR	# FINISHED WITH THIS GROUP, GET NEXT ONE

ITSAVAR		MASK	OCT1400		# IS IT TYPE B ?
		CCS	A
		TCF	ITSLIKEB	# YES, IT IS TYPE B

		EXTEND			# STORES THE JOB (OR TASK) 2CADR FOR EXIT
		NDX	TEMP2G
		DCA	PHSNAME1
		DXCH	GOLOC

		CA	TEMPPHS		# SEE IF THIS IS A JOB, TASK, OR A LONGCALL
		MASK	OCT7
		AD	MINUS2
		CCS	A
		TCF	ITSLNGCL	# IT'S A LONGCALL

# Page 1415
RTRNCADR	TC	SWRETURN	# CAN'T GET HERE.
		TCF	ITSAWAIT

		TCF	ITSAJOB		# IT'S A JOB

ITSAWAIT	CA	WTLTCADR	# SET UP WAITLIST CALL
		TS	GOLOC -1

		NDX	TEMP2G		# DIRECTLY STORED
		CA	PHSPRDT1
TIMETEST	CCS	A		# IS IT AN IMMEDIATE RESTART
		INCR	A		# NO.
		TCF	FINDTIME	# FIND OUT WHEN IT SHOULD BEGIN

		TCF	ITSINDIR	# STORED INDIRECTLY

		TCF	IMEDIATE	# IT WANTS AN IMMEDIATE RESTART

# ***** THIS MUST BE IN FIXED FIXED *****

		BLOCK	02
		SETLOC	FFTAG2
		BANK

		COUNT	02/RSROU
		
ITSINDIR	LXCH	GOLOC +1	# GET THE CORRECT E BANK IN CASE THIS IS
		LXCH	BB		# SWITCHED ERASABLE

		NDX	A		# GET THE TIME INDIRECTLY
		CA	1

		LXCH	BB		# RESTORE THE BB AND GOLOC
		LXCH	GOLOC +1

		TCF	FINDTIME	# FIND OUT WHEN IT SHOULD BEGIN

# ***** YOU MAY RETURN TO SWITCHED FIXED *****

		BANK 	01
		SETLOC	RESTART
		BANK

		COUNT	01/RSROU
		
FINDTIME	COM			# MAKE NEGATIVE SINCE IT WILL BE SUBTRACTED
		TS	L		# AND SAVE
		NDX	TEMP2G
		CS	TBASE1
		EXTEND
# Page 1416
		SU	TIME1
		CCS	A
		COM
		AD	OCT37776
		AD	ONE
		AD	L
		CCS	A
		CA	ZERO
		TCF	+2
		TCF	+1
IMEDIATE	AD	ONE
		TC	GOLOC -1
ITSLIKEB	CA	RTRNCADR	# TYPE B, SO STORE RETURN IN
		TS	TEMPSWCH	# TEMPSWCH IN CASE OF AN EVEN PHASE

		CA	PRT2CADR	# SET UP EXIT TO GET TABLE PART OF THIS
		TS	GOLOC +2	# VARIABLE TYPE OF PHASE

		CA	TEMPPHS		# MAKE THE PHASE LOOK RIGHT FOR THE TABLE
		MASK	OCT177		# PART OF THIS VARIABLE PHASE
		TS	TEMPPHS

		EXTEND
		NDX	TEMP2G		# OBTAIN THE JOB'S 2CADR
		DCA	PHSNAME1
		DXCH	GOLOC

ITSAJOB		NDX	TEMP2G		# NOW ADD THE PRIORITY AND LET'S GO
		CA	PHSPRDT1
CHKNOVAC	TS	GOLOC -1	# SAVE PRIO UNTIL WE SEE IF IT'S
		EXTEND			# A FINDVAC OR A NOVAC
		BZMF	ITSNOVAC

		CAF	FVACCADR	# POSITIVE, SET UP FINDVAC CALL.
		XCH	GOLOC -1	# PICK UP PRIO
		TC	GOLOC -1	AND GO

ITSNOVAC	CAF	NOVACADR	# NEGATIVE,
		XCH	GOLOC -1	# SET UP NOVAC CALL,
		COM			# CORRECT PRIO,
		TC	GOLOC -1	# AND GO

ITSATBL		TS	CYR		# FIND OUT IF THE PHASE IS ODD OR EVEN
		CCS	CYR
		TCF	+1		# IT'S EVEN
		TCF	ITSEVEN

		CA	RTRNCADR	# IN CASE THIS IS THE SECOND PART OF A
		TS	GOLOC +2	# TYPE B RESTART, WE NEED PROPER EXIT
# Page 1417
		CA	TEMPPHS		# SET UP POINTER FOR FINDING OUR PLACE IN
		TS	SR		# THE RESTART TABLES
		AD	SR
		NDX	TEMP2G
		AD	SIZETAB +1
		TS	POINTER

CONTBL2		EXTEND			# FIND OUT WHAT'S IN THE TABLE
		NDX	POINTER
		DCA	CADRTAB		# GET THE 2CADR

		LXCH	GOLOC +1	# STORE THE BB INFORMATION

		CCS	A		# IS IT A JOB OR IT IT TIMED
		INCR	A		# POSITIVE, MUST BE A JOB
		TCF	ITSAJOB2

		INCR	A		# MUST BE EITHER A WAITLIST OR LONGCALL
		TS	GOLOC		# LET'S STORE THE CORRECT CADR

		CA	WTLTCADR	# SET UP OUR EXIT TO WAITLIST
		TS	GOLOC -1

		CA	GOLOC +1	# NOW FIND OUT IF IT IS A WAITLIST CALL
		MASK	BIT10		# THIS SHOULD BE ONE IF WE HAVE -BB
		CCS	A		# FOR THAT MATTER SO SHOULD BE BITS 9,8,7,
					# 6,5, AND LAST BUT NOT LEAST (PERHAPS NOT
					# IN IMPORTANCE ANYWAY.  BUT 4
		TCF	ITSWTLST	# IT IS A WAITLIST CALL

		NDX	POINTER		# OBTAIN THE ORIGINAL DELTA T
		CA	PRDTTAB		# ADDRESS FOR THIS LONGCALL

		TCF	ITSLGCL1	# NOW GO GET THE DELTA TIME

# ***** THIS MUST BE IN FIXED FIXED *****

		BLOCK	02
		SETLOC	FFTAG2
		BANK

		COUNT	02/RSROU
		
ITSLGCL1	LXCH	GOLOC +1	# OBTAIN THE CORRECT E BANK
		LXCH	BB
		LXCH	GOLOC +1	# AND PRESERVE OUR E AND F BANKS

		EXTEND			# GET THE DELTA TIME
		NDX	A
		DCA	0
# Page 1418
		LXCH	GOLOC +1	# RESTORE OUR E AND F BANK
		LXCH	BB		# RESTORE THE TASKS E AND F BANKS
		LXCH	GOLOC +1	# AND PRESERVE OUR L
		TCF	ITSLGCL2	# NOT GET'S PROCESS THIS LONGCALL

# ***** YOU MAY RETURN TO SWITCHED FIXED *****

		BANK	01
		SETLOC	RESTART
		BANK

		COUNT	01/RSROU
ITSLGCL2	DXCH	LONGTIME

		EXTEND			# CALCULATE TIME LEFT
		DCS	TIME2
		DAS	LONGTIME
		EXTEND
		DCA	LONGBASE
		DAS	LONGTIME

		CCS	LONGTIME	# FIND OUT HOW THIS SHOULD BE RESTARTED
		TCF	LONGCLCL
		TCF	+2
		TCF	IMEDIATE -3
		CCS	LONGTIME +1
		TCF	LONGCLCL
		NOOP			# CAN'T GET HERE ************
		TCF	IMEDIATE -3
		TCF	IMEDIATE

LONGCLCL	CA	LGCLCADR	# WE WILL GO TO LONGCALL
		TS	GOLOC -1

		EXTEND			# PREPARE OUR ENTRY TO LONGCALL
		DCA	LONGTIME
		TC	GOLOC -1

ITSLNGCL	CA	WTLTCADR	# ASSUME IT WILL GO TO WAITLIST
		TS	GOLOC -1

		NDX	TEMP2G
		CS	PHSPRDT1	# GET THE DELTA T ADDRESS

		TCF	ITSLGCL1	# NOW GET THE DELTA TIME

ITSWTLST	CS	GOLOC +1	# CORRECT THE BBCON INFORMATION
		TS	GOLOC +1
# Page 1419
		NDX	POINTER		# GET THE DT AND FIND OUT IF IT WAS STORED
		CA	PRDTTAB		# DIRECTLY OR INDIRECTLY

		TCF	TIMETEST	# FIND OUT HOW THE TIME IS STORED

ITSAJOB2	XCH	GOLOC		# STORE THE CADR

		NDX	POINTER		# ADD THE PRIORITY AND LET'S GO
		CA	PRDTTAB

		TCF	CHKNOVAC

ITSEVEN		CA	TEMPSWCH	# SET FOR EITHER THE SECOND PART OF THE
		TS	GOLOC +2	# TABLE, OR A RETURN FOR THE NEXT GROUP

		NDX	TEMP2G		# SET UP POINTER FOR OUR LOCATION WITHIN
		CA	SIZETAB		# THE TABLE
		AD	TEMPPHS		# THIS MAY LOOK BAD BUT LET'S SEE YOU DO
		AD	TEMPPHS		# BETTER IN TIME OR NUMBER OF LOCATIONS
		AD	TEMPPHS
		TS	POINTER

		TCF	CONTBL2		# NO PROCESS WHAT IS IN THE TABLE

PHSPART2	CA	THREE		# SET THE POINTER FOR THE SECOND HALF OF
		ADS	POINTER		# THE TABLE

		CA	RTRNCADR	# THIS WILL BE OUR LAST TIME THROUGH THE
		TS	GOLOC +2	# EVEN TABLE, SO AFTER IT GET THE NEXT
					# GROUP
		TCF	CONTBL2		# SO LET'S GET THE SECOND ENTRY IN THE TBL

TEMPPHS		EQUALS	MPAC
TEMP2G		EQUALS	MPAC +1
POINTER		EQUALS	MPAC +2
TEMPSWCH	EQUALS	MPAC +3
GOLOC		EQUALS	VAC5 +20D
MINUS2		EQUALS	NEG2
OCT177		EQUALS	LOW7

PHS2CADR	GENADR	PHSPART2
PRT2CADR	GENADR	GETPART2
LGCLCADR	GENADR	LONGCALL
FVACCADR	GENADR	FINDVAC
WTLTCADR	GENADR	WAITLIST
NOVACADR	GENADR	NOVAC




