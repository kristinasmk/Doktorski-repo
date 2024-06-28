%List = lista (ulaz, znakovi) 
%ova funkcija dodaje na stupac podataka (cell) znakove po želji
% svrha ove funkcije je da se promijeni ime podataka koji æe se kasnije
% koristiti u nazivlju jer takvi podaci ne smiju poèinjati s brojem
%
% ulaz - stupac podataka na koji se dodaju znakovi
% znakovi - slova koja se žele nadodati na podatke (mora poèet i završitit
% s apostrofima, primjer. 'AC')

function List = lista (ulaz, znakovi)

lists=cell(numel(ulaz),1);
list2=cellfun('isempty',lists);
lists(list2)={znakovi};

charUlaz = cellfun(@num2str, ulaz, 'UniformOutput', false);
charLists = cellfun(@char, lists, 'UniformOutput', false);

List= strcat(charLists, charUlaz);
List=cellstr(List);

end