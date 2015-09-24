function varargout = CH(varargin)
% CH M-file for CH.fig
%      CH, by itself, creates a new CH or raises the existing
%      singleton*.
%
%      H = CH returns the handle to a new CH or the handle to
%      the existing singleton*.
%
%      CH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CH.M with the given input arguments.
%
%      CH('Property','Value',...) creates a new CH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CH_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CH_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CH

% Last Modified by GUIDE v2.5 29-Feb-2008 13:27:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CH_OpeningFcn, ...
                   'gui_OutputFcn',  @CH_OutputFcn, ...
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


% --- Executes just before CH is made visible.
function CH_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CH (see VARARGIN)

% Choose default command line output for CH
handles.output = hObject;

% Initialize required objInfo variables
handles.objInfo.currentTurn = [];
handles.objInfo.colors = [];
handles.objInfo.teamLocs = [];
handles.objInfo.pieceNums = [];
handles.objInfo.pieceStrs = [];
handles.objInfo.squareHandles = [];
handles.objInfo.rowcol = [];
handles.objInfo.check = [0 0];
handles.objInfo.currentDir = cd;
handles.objInfo.pieceMaps = loadPieceMaps(handles);


% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = CH_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function loadm_Callback(hObject, eventdata, handles)
% hObject    handle to loadm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Throw load dialog box
[fileName pathName filterIndex] = uigetfile({'*.mat'},'Load Game');

% If filename was selected, load file
if fileName ~= 0
    load([pathName fileName]);
    handles.objInfo = data;
end

% Run initialization function
handles = populateSquares(handles,hObject);

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function savem_Callback(hObject, eventdata, handles)
% hObject    handle to savem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Extract important elements of handles structure HERE
data = handles.objInfo;

% Throw dialog box
[fileName pathName filterIndex] = uiputfile({'*.mat'},'Save Game','game1.mat');

% Save data
if fileName ~= 0
    save([pathName fileName],'data');
end



% --------------------------------------------------------------------
function quitm_Callback(hObject, eventdata, handles)
% hObject    handle to quitm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

b = questdlg('Do you really wish to quit?','Quit Game','Yes','No','Yes');
if strcmp(b,'Yes')
    closereq;
else
    return
end




% --------------------------------------------------------------------
function gm_Callback(hObject, eventdata, handles)
% hObject    handle to gm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function newm_Callback(hObject, eventdata, handles)
% hObject    handle to newm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Setup variables and board
handles.objInfo.teamLocs = zeros(8,8);
handles.objInfo.teamLocs(1:2,:) = 1;
handles.objInfo.teamLocs(7:8,:) = 2;

handles.objInfo.pieceNums = zeros(8,8);
handles.objInfo.pieceNums([2 7],:) = 1;
handles.objInfo.pieceNums([1 8],[1 8]) = 2;
handles.objInfo.pieceNums([1 8],[2 7]) = 3;
handles.objInfo.pieceNums([1 8],[3 6]) = 4;
handles.objInfo.pieceNums(1,4) = 6;
handles.objInfo.pieceNums(8,5) = 5;
handles.objInfo.pieceNums(1,5) = 5;
handles.objInfo.pieceNums(8,4) = 6;

% Initialize currentTurn and colors values
handles.objInfo.currentTurn = 1;
handles.objInfo.colors = {[1 0 0],[0 0 1]};
% Fill squares with characters representing pieces, and set appropriate
% callback functions
handles = populateSquares(handles,hObject);
% Update handles structure
guidata(hObject, handles);


function setupMove(hObject,eventdata,handles)
% Find index for selected piece
ndx = find(handles.objInfo.squareHandles == hObject);
[r c] = ind2sub([8 8],ndx);
% Check that current player's piece was selected
if handles.objInfo.currentTurn == handles.objInfo.teamLocs(r,c)
    % Get moves for that piece
    m = showMoves(handles,r,c,0);
    % Set callbacks
    set(handles.objInfo.squareHandles(find(m)),'CallBack','CH(''confirmMove'',gcbo,[],guidata(gcbo))');
    set(handles.objInfo.squareHandles(find(~m)),'Callback','');
    set(hObject,'CallBack','CH(''cancelMove'',gcbo,[],guidata(gcbo))');
    handles.objInfo.rowcol = [r c];
	% Fix imagemaps
    tLoc = handles.objInfo.currentTurn;
    tag = ['a' num2str(r) num2str(c)];
    bgc = eval(['get(handles.' tag ',''BackGroundColor'');']);
    pLoc = handles.objInfo.pieceNums(r,c);
    pmapRow = pLoc;
    if tLoc == 1 && all(bgc == 1)
        pmapCol = 1;
    elseif tLoc == 1 && all(bgc == 0);
        pmapCol = 2;
    elseif tLoc == 2 && all(bgc == 1)
        pmapCol = 3;
    elseif tLoc == 2&& all(bgc == 0)
        pmapCol = 4;
    end
    cdata = handles.objInfo.pieceMaps;
    curCdata = cdata{pmapRow,pmapCol};
    if tLoc == 1
        q = curCdata(:,:,2) == 0 & curCdata(:,:,1) ~= 0;
    else
        q = curCdata(:,:,2) == 0 & curCdata(:,:,3) ~= 0;
    end
    [rr cc] = find(~q);
    ths = sub2ind([55,55,3],rr,cc,repmat(3,size(rr,1),1));
    tws = sub2ind([55,55,3],rr,cc,repmat(2,size(rr,1),1));
    ons = sub2ind([55,55,3],rr,cc,repmat(1,size(rr,1),1));
    if tLoc == 1
        curCdata(:,:,1) = 255;
        curCdata(ths) = 175;
        curCdata(tws) = 175;
    else
        curCdata(:,:,3) = 255;
        curCdata(ons) = 175;
        curCdata(tws) = 175;
    end
    eval(['set(handles.' tag ',''CData'',curCdata);']);
    guidata(hObject, handles);
else
    % Do nothing if selected piece was not owned by current player
    return  
end


function confirmMove(hObject,eventdata,handles)
% Get player and opponent turn values
pTurn = handles.objInfo.currentTurn;
switch pTurn
    case 1
        oTurn = 2;
    case 2
        oTurn = 1;
end
% Get row and column to and from values
rowFrom = handles.objInfo.rowcol(1);
colFrom = handles.objInfo.rowcol(2);
selectedHandle = handles.objInfo.squareHandles(sub2ind([8 8],rowFrom,colFrom));
[rowTo colTo] = ind2sub([8 8],find(handles.objInfo.squareHandles == hObject));
% Run checkSelf to determine whether the move was valid or not
invalidMove = checkSelf(handles,rowTo,colTo,rowFrom,colFrom);
% Return if move was invalid
if invalidMove
    return
else
    % Check for pawn promotion
    if handles.objInfo.pieceNums(rowFrom, colFrom) == 1
        if (handles.objInfo.currentTurn == 1 && rowTo == 8) || (handles.objInfo.currentTurn == 2 && rowTo == 1)
            handles.objInfo.pieceNums(rowFrom,colFrom) = 5;
            populateSquares(handles,hObject);
        end
    end
    % Run checkOpp to determine whether opponent is in check as a result of
    % selected move
    oppinCheck = checkOpp(handles,rowTo,colTo,rowFrom,colFrom);
    % Run checkMATE diagnostic
    if oppinCheck
        mCheck = mateCheck(handles,rowTo,colTo,rowFrom,colFrom);
    else
        mCheck = false;
    end
    % If oopnent in check, but not mate
    if oppinCheck && ~mCheck
        % Display check message if opponent in check, and update check
        % variable
        handles.objInfo.check(oTurn) = 1;
        switch oTurn
            case 1
                set(handles.rchkbox,'Visible','on');
            case 2
                set(handles.bchkbox,'Visible','on');
        end
    elseif ~oppinCheck && ~mCheck
        % Set check variable and turn off check warnings
        handles.objInfo.check(pTurn) = 0;
        switch oTurn
            case 1
                set(handles.bchkbox,'Visible','off');
            case 2
                set(handles.rchkbox,'Visible','off');
        end
        drawnow;
    elseif oppinCheck && mCheck
        endGame(handles);
        eval(['set(handles.a' num2str(rowTo) num2str(colTo) ',''CData'',get(handles.a' num2str(rowFrom) num2str(colFrom) ',''CData''));']);
        eval(['set(handles.a' num2str(rowFrom) num2str(colFrom) ',''CData'',[]);']);
        return;
    end
    % Carry out move
    handles.objInfo.teamLocs(rowTo,colTo) = handles.objInfo.teamLocs(rowFrom,colFrom);
    handles.objInfo.teamLocs(rowFrom,colFrom) = 0;
    handles.objInfo.pieceNums(rowTo,colTo) = handles.objInfo.pieceNums(rowFrom,colFrom);
    handles.objInfo.pieceNums(rowFrom,colFrom) = 0;
    % Turn off player turn box for current player
    switch pTurn
        case 1
            set(handles.rchkbox,'visible','off');
        case 2
            set(handles.bchkbox,'visible','off');
    end
    % Set currentTurn variable
    if handles.objInfo.currentTurn == 1
        handles.objInfo.currentTurn = 2;
    else
        handles.objInfo.currentTurn = 1;
    end
    % Set all callbacks to nothing
    set(handles.objInfo.squareHandles,'CallBack','');
    % Repopulate squares
    handles = populateSquares(handles,hObject);
    % Un-highlighted previously selected piece
    set(selectedHandle,'Value',0);
end

% Update handles structure
guidata(hObject, handles);



function cancelMove(hObject,eventdata,handles)
% Find current players pieces
a = find(handles.objInfo.teamLocs == handles.objInfo.currentTurn);
% Reset callbacks for those objects to setupMove
set(handles.objInfo.squareHandles(a),'CallBack','CH(''setupMove'',gcbo,[],guidata(gcbo))');
% Un-highlight piece
b = find(handles.objInfo.squareHandles == hObject);
[r c] = ind2sub([8 8],b);
tLoc = handles.objInfo.currentTurn;
bgc = eval(['get(hObject,''BackGroundColor'');']);
pLoc = handles.objInfo.pieceNums(r,c);
pmapRow = pLoc;
if tLoc == 1 && all(bgc == 1)
    pmapCol = 1;
elseif tLoc == 1 && all(bgc == 0);
    pmapCol = 2;
elseif tLoc == 2 && all(bgc == 1)
    pmapCol = 3;
elseif tLoc == 2&& all(bgc == 0)
    pmapCol = 4;
end
eval(['set(hObject,''CData'',handles.objInfo.pieceMaps{' num2str(pmapRow) ',' num2str(pmapCol) '});']);


% set(hObject,'FontWeight','normal');
% set(hObject,'fontsize',8);


function m = showMoves(handles,row,col,check)
% Get pieceNum for selected piece, then obtain moves based on this value
pieceNum = handles.objInfo.pieceNums(row,col);
switch pieceNum
    case 1
        m = pawnMoves(handles,row,col,check);
    case 2
        m = rookMoves(handles,row,col,check);
    case 3
        m = knightMoves(handles,row,col,check);
    case 4
        m = bishopMoves(handles,row,col,check);
    case 5
        m = queenMoves(handles,row,col,check);
    case 6
        m = kingMoves(handles,row,col,check);
end


function m = pawnMoves(handles,row,col,check)
% Algorithm for pawn moving rules
m = zeros(8,8);
% Red turn
if handles.objInfo.currentTurn == 1
    if handles.objInfo.teamLocs(row+1,col) == 0
        m(row+1,col) = 1;
    end
    if row == 2 
        if handles.objInfo.teamLocs(row+2,col) == 0
            m(row+2,col) = 1;
        end
    end
    if col ~= 8
        if handles.objInfo.teamLocs(row+1,col+1) == 2;
            m(row+1,col+1) = 1;
        end
    end
    if col ~= 1
        if handles.objInfo.teamLocs(row+1,col-1) == 2
            m(row+1,col-1) = 1;
        end
    end
% Blue turn    
elseif handles.objInfo.currentTurn == 2
    if handles.objInfo.teamLocs(row-1,col) == 0
        m(row-1,col) = 1;
    end
    if row == 7 
        if handles.objInfo.teamLocs(row-2,col) == 0
            m(row-2,col) = 1;
        end
    end
    if col ~= 8
        if handles.objInfo.teamLocs(row-1,col+1) == 1;
            m(row-1,col+1) = 1;
        end
    end
    if col ~= 1
        if handles.objInfo.teamLocs(row-1,col-1) == 1
            m(row-1,col-1) = 1;
        end
    end
end
% Remove any moves to take opponents king
if ~check
    m(handles.objInfo.pieceNums == 6) = 0;
end


function m = knightMoves(handles,row,col,check)
% Algorithm for knight movement rules
m = zeros(14,14);
modrow = row + 3;
modcol = col + 3;
m(modrow+2,[modcol+1 modcol-1]) = 1;
m(modrow-2,[modcol+1 modcol-1]) = 1;
m(modrow+1,[modcol+2 modcol-2]) = 1;
m(modrow-1,[modcol+2 modcol-2]) = 1;
m = m(4:end-3,4:end-3);
ndx = find(m);
% Remove moves that result in taking opponents king
if ~check
    m(handles.objInfo.pieceNums == 6) = 0;
end
% Remove moves that land on current players pieces
excl = ndx(ismember(ndx,find(handles.objInfo.teamLocs == handles.objInfo.currentTurn)));
m(excl) = 0;


function m = rookMoves(handles,row,col,check)
% Algorithm for rook movement rules
m = zeros(8,8);

% Propagate left if necessary
if col > 1
    cix = col - 1;
    while (cix > 0 && handles.objInfo.teamLocs(row,cix) < 1) 
        m(row,cix) = 1;
        cix = cix-1;
    end
    if cix > 0 && handles.objInfo.teamLocs(row,cix) ~= handles.objInfo.currentTurn
        m(row,cix) = 1;
    end
end

% Propagate right if necessary
if col < 8
    cix = col + 1;
    while (cix < 9 && handles.objInfo.teamLocs(row,cix) < 1)
        m(row,cix) = 1;
        cix = cix+1;
    end
    if cix < 9 && handles.objInfo.teamLocs(row,cix) ~= handles.objInfo.currentTurn
        m(row,cix) = 1;
    end
end

% Propagate up if necessary
if row > 1
    rix = row - 1;
    while (rix > 0 && handles.objInfo.teamLocs(rix,col) < 1) 
        m(rix,col) = 1;
        rix = rix-1;
    end
    if rix > 0 && handles.objInfo.teamLocs(rix,col) ~= handles.objInfo.currentTurn
        m(rix,col) = 1;
    end
end

% Propagate down if necessary
if row < 8
    rix = row + 1;
    while (rix < 9 && handles.objInfo.teamLocs(rix,col) < 1) 
        m(rix,col) = 1;
        rix = rix+1;
    end
    if rix < 9 && handles.objInfo.teamLocs(rix,col) ~= handles.objInfo.currentTurn
        m(rix,col) = 1;
    end
end

% Remove moves that take opponents king
if ~check
    m(handles.objInfo.pieceNums == 6) = 0;
end
% Remove any moves that end on current players pieces
m(handles.objInfo.teamLocs == handles.objInfo.currentTurn) = 0;



function m = bishopMoves(handles,row,col,check)
% Bishop movement algorithm
m = zeros(8,8);
colLft = col-1:-1:1;
colRt = col+1:8;
rowUp = row-1:-1:1;
rowDwn = row+1:8;
dwnRightNum = min(numel(rowDwn),numel(colRt));
dwnLeftNum = min(numel(rowDwn),numel(colLft));
upRightNum = min(numel(rowUp),numel(colRt));
upLeftNum = min(numel(rowUp),numel(colLft));
dwnRightNdx = [rowDwn(1:dwnRightNum) ; colRt(1:dwnRightNum)];
dwnLeftNdx = [rowDwn(1:dwnLeftNum) ; colLft(1:dwnLeftNum)];
upRightNdx = [rowUp(1:upRightNum) ; colRt(1:upRightNum)];
upLeftNdx = [rowUp(1:upLeftNum) ; colLft(1:upLeftNum)];
ul = sub2ind([8 8],upLeftNdx(1,:),upLeftNdx(2,:));
ur = sub2ind([8 8],upRightNdx(1,:),upRightNdx(2,:));
dl = sub2ind([8 8],dwnLeftNdx(1,:),dwnLeftNdx(2,:));
dr = sub2ind([8 8],dwnRightNdx(1,:),dwnRightNdx(2,:));
ulnum = find(handles.objInfo.teamLocs(ul) ~= 0,1,'first');
urnum = find(handles.objInfo.teamLocs(ur) ~= 0,1,'first');
dlnum = find(handles.objInfo.teamLocs(dl) ~= 0,1,'first');
drnum = find(handles.objInfo.teamLocs(dr) ~= 0,1,'first');
m(ul(1:ulnum)) = 1;
m(ur(1:urnum)) = 1;
m(dl(1:dlnum)) = 1;
m(dr(1:drnum)) = 1;
if isempty(ulnum)
    m(ul) = 1;
end
if isempty(urnum)
    m(ur) = 1;
end
if isempty(dlnum)
    m(dl) = 1;
end
if isempty(drnum)
    m(dr) = 1;
end
if ~check
    m(handles.objInfo.pieceNums == 6) = 0;
end
m(handles.objInfo.teamLocs == handles.objInfo.currentTurn) = 0;


function m = queenMoves(handles,row,col,check)
% Get queen moves by merging bishop and rook moves
m1 = bishopMoves(handles,row,col,check);
m2 = rookMoves(handles,row,col,check);
m = double(m1 | m2);

function m = kingMoves(handles,row,col,check)
% Get king moves by using queens moves and truncating
m1 = queenMoves(handles,row,col,check);
r = reshape(repmat(row-1:row+1,3,1),9,1);
c = reshape(repmat(col-1:col+1,1,3),9,1);
ndx = r >= 1 & r <=8 & c >=1 & c <=8;
r = r(ndx);
c = c(ndx);
m = zeros(8,8);
m(r,c) = m1(r,c);


function handles = populateSquares(handles,hObject)
% Get handles for all board squares
handles.objInfo.squareHandles = zeros(64,1);
for i = 1:64
    % Get row/col index
    [r c] = ind2sub([8 8],i);
    % Get tag from row/col
    tag = ['a' num2str(r) num2str(c)];
    % Check if row/col occupied
    tLoc = handles.objInfo.teamLocs(r,c);
    pLoc = handles.objInfo.pieceNums(r,c);
    if tLoc ~= 0
        bgc = eval(['get(handles.' tag ',''BackGroundColor'');']);
        pmapRow = pLoc;
        if tLoc == 1 && all(bgc == 1)
            pmapCol = 1;
        elseif tLoc == 1 && all(bgc == 0);
            pmapCol = 2;
        elseif tLoc == 2 && all(bgc == 1)
            pmapCol = 3;
        elseif tLoc == 2&& all(bgc == 0)
            pmapCol = 4;
        end
        eval(['set(handles.' tag ',''CData'',handles.objInfo.pieceMaps{' num2str(pmapRow) ',' num2str(pmapCol) '});']);
    else
        eval(['set(handles.' tag ',''CData'',[]);']);
    end
    % Set handles.objInfo.squareHandles vector
    eval(['handles.objInfo.squareHandles(i,1) = handles.' tag ';']);
end


% Set callbacks for current turn's pieces to setupMoves
r = find(handles.objInfo.currentTurn == handles.objInfo.teamLocs);
set(handles.objInfo.squareHandles(r),'Callback','CH(''setupMove'',gcbo,[],guidata(gcbo))');
set(handles.objInfo.squareHandles(find(handles.objInfo.currentTurn ~= handles.objInfo.teamLocs)),'Callback','');
% Display turn messages
if handles.objInfo.currentTurn == 1
    set(handles.rdturn,'String','Red''s Turn','Visible','on');
    set(handles.bpturn,'String','Blue''s Turn','Visible','off');
else
    set(handles.rdturn,'String','Red''s Turn','Visible','off');
    set(handles.bpturn,'String','Blue''s Turn','Visible','on');
end
% Display check messages (if required)
if handles.objInfo.check(1) == 1
    set(handles.rchkbox,'String','Red is in check!','visible','on');
elseif handles.objInfo.check(1) == 0
    set(handles.rchkbox,'String','Red is in check!','visible','off');
end
if handles.objInfo.check(2) == 1
    set(handles.bchkbox,'String','Blue is in check!','visible','on');
elseif handles.objInfo.check(2) == 0
    set(handles.bchkbox,'String','Blue is in check!','visible','off');    
end
% Show/hide the captured pieces panel
set([handles.uipanel2 handles.uipanel3],'Visible','off');
% Flip white king/queen
%handles.objInfo.pieceNums(1,[4,5]) = handles.objInfo.pieceNums(1,[5,4]);
% Update handles structure
guidata(hObject, handles);


function tf = checkSelf(handles,rowTo,colTo,rowFrom,colFrom)
% Get oTurn and pTurn values
pTurn = handles.objInfo.currentTurn;
switch pTurn
    case 1
        oTurn = 2;
    case 2
        oTurn = 1;
end
% Move pieces to test for check conditions
handles.objInfo.teamLocs(rowTo,colTo) = pTurn;
handles.objInfo.teamLocs(rowFrom,colFrom) = 0;
handles.objInfo.pieceNums(rowTo,colTo) = handles.objInfo.pieceNums(rowFrom,colFrom);
handles.objInfo.pieceNums(rowFrom,colFrom) = 0;
handles.objInfo.currentTurn = oTurn;
% Get index for own king piece
[pkr pkc] = find(handles.objInfo.pieceNums == 6 & handles.objInfo.teamLocs == pTurn);
pklndx = sub2ind([8 8],pkr,pkc);
% Get indices for oppositions pieces
[opcr opcc] = find(handles.objInfo.teamLocs == oTurn);
% Loop to obtain check values
chVec = false(size(opcr));
for i = 1:size(opcr,1)
    m = showMoves(handles,opcr(i),opcc(i),1);
    a = find(m);
    if any(ismember(a,pklndx))
        chVec(i) = true;
    end
end
% If any piece results in check, throw true, else false
tf = any(chVec);



function tf = checkOpp(handles,rowTo,colTo,rowFrom,colFrom)
% Function to test opponents pieces for check
pTurn = handles.objInfo.currentTurn;
switch pTurn
    case 1
        oTurn = 2;
    case 2
        oTurn = 1;
end
handles.objInfo.teamLocs(rowTo,colTo) = pTurn;
handles.objInfo.teamLocs(rowFrom,colFrom) = 0;
handles.objInfo.pieceNums(rowTo,colTo) = handles.objInfo.pieceNums(rowFrom,colFrom);
handles.objInfo.pieceNums(rowFrom,colFrom) = 0;
[okr okc] = find(handles.objInfo.pieceNums == 6 & handles.objInfo.teamLocs == oTurn);
oklndx = sub2ind([8 8],okr,okc);
[ppcr ppcc] = find(handles.objInfo.teamLocs == pTurn);
chVec = false(size(ppcr));
for i = 1:size(ppcr,1)
    m = showMoves(handles,ppcr(i),ppcc(i),1);
    a = find(m);
    if any(ismember(a,oklndx))
        chVec(i) = true;
    end
end
tf = any(chVec);



function tf = mateCheck(handles,rowTo,colTo,rowFrom,colFrom)
% Test for check mate
pTurn = handles.objInfo.currentTurn;
switch pTurn
    case 1
        oTurn = 2;
    case 2
        oTurn = 1;
end
handles.objInfo.teamLocs(rowTo,colTo) = pTurn;
handles.objInfo.teamLocs(rowFrom,colFrom) = 0;
handles.objInfo.pieceNums(rowTo,colTo) = handles.objInfo.pieceNums(rowFrom,colFrom);
handles.objInfo.pieceNums(rowFrom,colFrom) = 0;
[r c] = find(handles.objInfo.teamLocs == oTurn);
handles.objInfo.currentTurn = oTurn;
chV = zeros(size(r,1),1);
for n = 1:size(chV,1)
    m = showMoves(handles,r(n),c(n),0);
    [r2 c2] = find(m);
    cs = zeros(size(r2,1),1);
    for i = 1:size(r2,1)
        cs(i) = checkSelf(handles,r2(i),c2(i),r(n),c(n));
    end
    chV(n) = all(cs);
end
tf = all(chV);    
    
    
function endGame(handles)
% Function to finalise game when a player has been placed in check-mate
winner = handles.objInfo.currentTurn;
set(handles.objInfo.squareHandles,'CallBack','');
if winner == 1
    set(handles.rchkbox,'String','Winner!!','Visible','on');
    set(handles.bchkbox,'String','Check mate! You Lose!','Visible','on');
elseif winner == 2
    set(handles.bchkbox,'String','Winner!!','Visible','on');
    set(handles.rchkbox,'String','Check mate! You Lose!','Visible','on');
end
set([handles.rdturn handles.bpturn],'String','Game Over');


function outputData = loadPieceMaps(handles)
% Function called on startup to load the image maps for all the pieces
directory = [handles.objInfo.currentDir '\PieceMaps\'];
outputData = cell(6,4);
alllist = struct2cell(dir(directory));
alllist = alllist(1,3:end);
alllist = sort(alllist);
nx = cellfun(@(x) ~isempty( regexp( x , '.bmp' , 'once' ) ) , alllist );
alllist(~nx) = [];
fnh = @(x) imread([directory x]);
r = cellfun(fnh,alllist,'UniformOutput',false);
wndx = cellfun(@(x) ~isempty(strfind(x,'W')),alllist);
rndx = cellfun(@(x) ~isempty(strfind(x,'Red')),alllist);
outputData(:,1) = r(wndx & rndx);
outputData(:,2) = r(~wndx & rndx);
outputData(:,3) = r(wndx & ~rndx);
outputData(:,4) = r(~wndx & ~rndx);






