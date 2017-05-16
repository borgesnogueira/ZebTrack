function varargout = exportfigs(varargin)
% EXPORTFIGS M-file for exportfigs.fig
%      EXPORTFIGS, by itself, creates a new EXPORTFIGS or raises the existing
%      singleton*.
%
%      H = EXPORTFIGS returns the handle to a new EXPORTFIGS or the handle to
%      the existing singleton*.
%
%      EXPORTFIGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTFIGS.M with the given input arguments.
%
%      EXPORTFIGS('Property','Value',...) creates a new EXPORTFIGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before exportfigs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to exportfigs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help exportfigs

% Last Modified by GUIDE v2.5 04-May-2013 18:00:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exportfigs_OpeningFcn, ...
                   'gui_OutputFcn',  @exportfigs_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before exportfigs is made visible.
function exportfigs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to exportfigs (see VARARGIN)

% Choose default command line output for exportfigs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes exportfigs wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = exportfigs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in abrir.
function abrir_Callback(hObject, eventdata, handles)
% hObject    handle to abrir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles.fn,handles.dir] = uigetfile('*.avi','Escolha o Video');
%abre o aquivo de video
handles.video = VideoReader([handles.dir,handles.fn]);

set(handles.exportar,'Enable','on')
guidata(hObject, handles);

% --- Executes on button press in exportar.
function exportar_Callback(hObject, eventdata, handles)
% hObject    handle to exportar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.sair,'Enable','off')
mkdir([handles.dir,'frames']);
h = waitbar(0,'Exportando...');
for i=1:handles.video.NumberOfFrames;
    frame = read(handles.video,i);
    imwrite(frame,[handles.dir,'frames\frame',int2str(i),'.jpeg'],'jpeg','Quality',100);
    waitbar(i / handles.video.NumberOfFrames);
end
close(h);
set(handles.sair,'Enable','on')
nframes = handles.video.NumberOfFrames;
save([handles.dir,'frames\nframes'],'nframes');

% --- Executes on button press in sair.
function sair_Callback(hObject, eventdata, handles)
% hObject    handle to sair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
