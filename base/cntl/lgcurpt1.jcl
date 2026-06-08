//LGCURPT1 JOB (ACCT),'CUSTOMER REPORT',
//         CLASS=A,
//         MSGCLASS=X,
//         MSGLEVEL=(1,1),
//         NOTIFY=&SYSUID
//*
//*****************************************************************
//* JOB NAME: LGCURPT1                                            *
//* PURPOSE:  Execute Customer Detail Report Batch Program        *
//* AUTHOR:   GENAPP DEVELOPMENT TEAM                             *
//* DATE:     2026-06-05                                          *
//*                                                               *
//* DESCRIPTION:                                                  *
//*   This job executes the LGCURPT1 COBOL program to generate   *
//*   a detailed report of all customers in the DB2 database.    *
//*   The report includes customer contact information and       *
//*   addresses.                                                  *
//*                                                               *
//* INPUTS:                                                       *
//*   - DB2 CUSTOMER table                                        *
//*                                                               *
//* OUTPUTS:                                                      *
//*   - CUSTRPT: Customer detail report file                      *
//*   - SYSOUT:  Job execution messages                           *
//*                                                               *
//* NOTES:                                                        *
//*   - Requires DB2 subsystem connection                         *
//*   - Program uses SQL cursor to read customer records          *
//*   - Report is formatted with page headers and totals          *
//*                                                               *
//* RETURN CODES:                                                 *
//*   0  - Successful completion                                  *
//*   16 - File open error or DB2 error                           *
//*                                                               *
//*****************************************************************
//*
//*****************************************************************
//* STEP010: Execute Customer Report Program                      *
//*****************************************************************
//STEP010  EXEC PGM=LGCURPT1,
//         REGION=4M
//*
//*****************************************************************
//* DB2 PLAN ALLOCATION                                           *
//*****************************************************************
//STEPLIB  DD DSN=DB2.V12R1M0.SDSNLOAD,
//            DISP=SHR
//         DD DSN=GENAPP.LOADLIB,
//            DISP=SHR
//*
//*****************************************************************
//* DB2 SYSTEM DATASETS                                           *
//*****************************************************************
//SYSTSIN  DD DUMMY
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSABOUT DD SYSOUT=*
//*
//*****************************************************************
//* OUTPUT REPORT FILE                                            *
//*****************************************************************
//CUSTRPT  DD DSN=GENAPP.CUSTOMER.REPORT,
//            DISP=(NEW,CATLG,DELETE),
//            UNIT=SYSDA,
//            SPACE=(CYL,(5,2),RLSE),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=13300)
//*
//*****************************************************************
//* DB2 RUNTIME DATASETS                                          *
//*****************************************************************
//SYSTSPRT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//*
//*****************************************************************
//* END OF JOB                                                    *
//*****************************************************************

//* Made with Bob
