function test
clear, clc

disp(tst);
close

num = 1;
vobj = videoinput('winvideo',1);

set(vobj,'FramesPerTrigger',num);
set(vobj,'TriggerRepeat', 4);
set(vobj,'ReturnedColorSpace','rgb')
set(vobj,'FramesAcquiredFcnCount',1);
%%%%
set(vobj,'StartFcn',@fcn_start);
set(vobj,'FramesAcquiredFcn',@fcn_acquire);
set(vobj,'TriggerFcn',@fcn_trigger);
set(vobj,'StopFcn',@fcn_stop);

get(vobj);
set(vobj,'UserData',{'Fuck'});
get(vobj,'UserData')
res = get(vobj,'VideoResolution');
res(1)

triggerinfo(vobj);
triggerconfig(vobj);

start(vobj);
% % [data tim] = getdata(vobj,num);

% % pause(5);
% % stop(vobj);


% % for ii=1:num
% %     imshow(data(:,:,:,ii));
% %     colormap(hsv(128))
% %     pause(0.2);
% %     disp(ii);
% % end


function fcn_start(obj,event)
disp('Start')

function fcn_trigger(obj,event)
disp('Trigger')

function fcn_acquire(obj,event)
disp('Acquire')
frm = peekdata(obj,1);
imagesc(frm);
drawnow;

function fcn_stop(obj,event)
disp('Stop')
delete(obj);
clear obj

function res = tst
res = true;
return;