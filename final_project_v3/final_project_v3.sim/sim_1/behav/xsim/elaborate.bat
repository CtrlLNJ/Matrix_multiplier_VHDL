@echo off
REM ****************************************************************************
REM Vivado (TM) v2017.4 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Tue Nov 27 19:34:35 +0000 2018
REM SW Build 2086221 on Fri Dec 15 20:55:39 MST 2017
REM
REM Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
call xelab  -wto a209e0c9b0d84810be327f2fedfadeff --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot top_level_tb_behav xil_defaultlib.top_level_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
