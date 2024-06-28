%List = lista (ulaz, znakovi) 
%ova funkcija dodaje na stupac podataka (cell) znakove po �elji
% svrha ove funkcije je da se promijeni ime podataka koji �e se kasnije
% koristiti u nazivlju jer takvi podaci ne smiju po�injati s brojem
%
% ulaz - stupac podataka na koji se dodaju znakovi
% znakovi - slova koja se �ele nadodati na podatke (mora po�et i zavr�itit
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