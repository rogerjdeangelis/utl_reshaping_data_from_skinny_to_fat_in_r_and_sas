Reshaping data from skinny to fat in R and SAS

https://goo.gl/CDdh4V
https://communities.sas.com/t5/SAS-Enterprise-Guide/creating-a-new-dataset-where-duplicate-rows-in-the-old-set-are/m-p/415253


Three solutions

INPUT
=====

 SD1.HAVE total obs=4  |     RULES
                       |
   C1    C2    C3      |   V1    V2    V3    V4    V5    V6
                       |
   A     B     C       |   A     B     C     A     D     E
   A     D     E       |   F     G     H     F     I     J
   F     G     H       |
   F     I     J       |

WORKING CODE
============

 SAS SOLUTION 1

  %utl_gather(sd1.have,name,val,,hav2nd,valformat=$1.);

  data want(keep=var:);
    retain var1-var6;
    array vars[0:5] $1 var1-var6;
    set hav2nd;
    idx=mod(_n_-1,6);
    vars[idx]=val;
    if idx=5 then do;
       output;
    end;
  run;quit;

 SAS SOLUTION 2

  data want;
    retain var1-var6 ' ';
    set sd1.have;
    array vars $1 var1-var6;
    if mod(_n_,2)=0 then do;
        str=cats(of c:);
        call pokelong(str,addrlong(var4),3);
        output;
    end;
    else do;
       str=cats(of c:);
       call pokelong(str,addrlong(var1),3);
    end;
    keep var:;
  run;quit;

  R (MOST OF THE CODE IS TO INTERFACE R AND SAS)

     want   <-as.data.frame(matrix(have,,6,byrow = TRUE));
     want[] <- lapply(want, as.character);

*                _                _       _
 _ __ ___   __ _| | _____      __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \    / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/   | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|    \__,_|\__,_|\__\__,_|

;
options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  input c1$ c2$ c3$;
cards;
A B C
A D E
F G H
F I J
;;;;
run;quit;


*____   ___  _    _   _ _____ ___ ___  _   _ ____
/ ___| / _ \| |  | | | |_   _|_ _/ _ \| \ | / ___|
\___ \| | | | |  | | | | | |  | | | | |  \| \___ \
 ___) | |_| | |__| |_| | | |  | | |_| | |\  |___) |
|____/ \___/|_____\___/  |_| |___\___/|_| \_|____/

;

*                _
 ___  __ _ ___  / |
/ __|/ _` / __| | |
\__ \ (_| \__ \ | |
|___/\__,_|___/ |_|

;

%utl_gather(sd1.have,name,val,,hav2nd,valformat=$1.);

data want(keep=var:);
  retain var1-var6;
  array vars[0:5] $1 var1-var6;
  set hav2nd;
  idx=mod(_n_-1,6);
  vars[idx]=val;
  if idx=5 then do;
     output;
  end;
run;quit;


*                ____
 ___  __ _ ___  |___ \
/ __|/ _` / __|   __) |
\__ \ (_| \__ \  / __/
|___/\__,_|___/ |_____|

;

data want;
  retain var1-var6 ' ';
  set sd1.have;
  array vars $1 var1-var6;
  if mod(_n_,2)=0 then do;
      str=cats(of c:);
      call pokelong(str,addrlong(var4),3);
      output;
  end;
  else do;
     str=cats(of c:);
     call pokelong(str,addrlong(var1),3);
  end;
  keep var:;
run;quit;

 *____
|  _ \
| |_) |
|  _ <
|_| \_\

;

%utl_submit_r64('
source("c:/program files/r/r-3.3.1/etc/Rprofile.site",echo=T);
library(haven);
library(SASxport);
have<-t(as.matrix(read_sas("d:/sd1/have.sas7bdat")));
have;
want<-as.data.frame(matrix(have,,6,byrow = TRUE));
want[] <- lapply(want, as.character);
want;
str(want);
write.xport(want,file="d:/xpt/have.xpt");
');


