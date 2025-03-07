function SektorffnungenACC = DailySectorsImport (workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  SEKTORFFNUNGENACC = IMPORTFILE(FILE) reads data from the first
%  worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the data as a cell array.
%
%  SEKTORFFNUNGENACC = IMPORTFILE(FILE, SHEET) reads from the specified
%  worksheet.
%
%  SEKTORFFNUNGENACC = IMPORTFILE(FILE, SHEET, DATALINES) reads from the
%  specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  SektorffnungenACC = importfile("C:\Users\pandrasi\OneDrive - Fakultet prometnih znanosti\Projekt\FMP met\FMPMet\Sector\20180602_12_13_Sektoröffnungen ACC.xlsx", "02.06.2018", [1, 22]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 08-Jul-2021 10:22:05

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [1, 70]; %ovo nije dobro jer su dimenzije excel sheeta nepoznate!
end

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 14);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":N" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["von", "bis", "AnzSektoren", "NorthSector", "VarName5", "EastSector", "VarName7", "SouthSector", "VarName9", "WestSector", "VarName11", "VarName12", "VarName13", "Bravo"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify variable properties
opts = setvaropts(opts, ["von", "bis", "AnzSektoren", "NorthSector", "VarName5", "EastSector", "VarName7", "SouthSector", "VarName9", "WestSector", "VarName11", "VarName12", "VarName13", "Bravo"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["von", "bis", "AnzSektoren", "NorthSector", "VarName5", "EastSector", "VarName7", "SouthSector", "VarName9", "WestSector", "VarName11", "VarName12", "VarName13", "Bravo"], "EmptyFieldRule", "auto");

% Import the data
SektorffnungenACC = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":N" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    SektorffnungenACC = [SektorffnungenACC; tb]; %#ok<AGROW>
end

%% Convert to output type
SektorffnungenACC = table2cell(SektorffnungenACC);
numIdx = cellfun(@(x) ~isnan(str2double(x)), SektorffnungenACC);
SektorffnungenACC(numIdx) = cellfun(@(x) {str2double(x)}, SektorffnungenACC(numIdx));
end