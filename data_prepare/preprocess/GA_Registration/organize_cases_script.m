% pat_dir=dir('0*');
% for k=1:length(pat_dir)
PATH = 'U:\Downloads\GAsegmentation\';
    pat_dir2=dir([PATH 'P*']);
    for k2=1:length(pat_dir2)
    OD_cube=dir([PATH pat_dir2(k2).name '/P*.tif']);
    if ~isempty(OD_cube)
%         mkdir([pat_dir2(k2).name ' OD']);
%         mkdir([pat_dir2(k2).name ' OD/Original_cubes']);
%         copyfile([pat_dir2(k2).name '/' OD_cube(1).name],[pat_dir2(k2).name ' OD/Original_cubes/' OD_cube(1).name],'f');
        copyfile([PATH pat_dir2(k2).name '/' OD_cube(1).name],[PATH 'Result\' OD_cube(1).name],'f');

    end
%     OS_cube=dir([pat_dir2(k2).name '/*OS*cube_z.img']);
%     if ~isempty(OS_cube)
%         mkdir([pat_dir2(k2).name ' OS']);
%         mkdir([pat_dir2(k2).name ' OS/Original_cubes']);
%         copyfile([pat_dir2(k2).name '/' OS_cube(1).name],[pat_dir2(k2).name ' OS/Original_cubes/' OS_cube(1).name],'f');
%         copyfile([pat_dir2(k2).name '/' OS_cube(1).name],[OS_cube(1).name],'f');
%     end
    end
% end