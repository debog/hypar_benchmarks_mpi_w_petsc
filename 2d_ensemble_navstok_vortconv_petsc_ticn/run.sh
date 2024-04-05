#!/bin/bash

# stuff to compile code that generates
# initial solution (and exact solution, if
# available)
COMPILER="gcc"
INIT_CODE="exact.c"
INIT_EXEC="INIT"
FLAGS="-lm"
aux_dir="aux"

# number of MPI ranks for this case
# MUST correspond to iproc in solver.inp
NPROC=8

# file for screen output
OUTFILE="out.log"

# make sure that stuff to run hypar
# is available
if [ "x$MPI_EXEC" = "x" ]; then
  echo "  ERROR: MPI_EXEC undefined."
fi
if [ "x$HYPAR_EXEC_W_PATH" = "x" ]; then
  echo "  ERROR: HYPAR_EXEC_W_PATH undefined."
fi

root_dir=$PWD

cd $root_dir/$aux_dir
$COMPILER $INIT_CODE $FLAGS -o $INIT_EXEC
if [ -f "$INIT_EXEC" ]; then
  echo "  compiled code to generate initial solution."
else
  echo "  failed to compile code to generate initial solution."
fi
cd $root_dir

echo "  generating initial solution ..."
$root_dir/$aux_dir/$INIT_EXEC 2>&1 > $OUTFILE
rm $root_dir/$aux_dir/$INIT_EXEC

echo "  running hypar ..."
if [ $NPROC = "1" ]; then
  $HYPAR_EXEC_W_PATH 2>&1 > $OUTFILE 
else
  $MPI_EXEC -n $NPROC $HYPAR_EXEC_OTHER_ARGS $HYPAR_EXEC_W_PATH 2>&1 >> $OUTFILE
fi
