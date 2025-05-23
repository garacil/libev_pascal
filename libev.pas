(*
  Autor: Germán Luis Aracil Boned
  Email: garacilb@gmail.com
  Proyecto: Binding Pascal para libev
  Descripción: Este archivo forma parte de un proyecto para utilizar la biblioteca libev desde Free Pascal.
  Fecha: 2025
*)

unit libev;

{$mode objfpc}{$H+}
{$packrecords c}

interface

uses
  ctypes, dynlibs;

const
  // Nombres de librería según la plataforma
  {$IFDEF WINDOWS}
  LIBEV_NAME = 'libev.dll';
  {$ELSE}
    {$IFDEF DARWIN}
    LIBEV_NAME = 'libev.dylib';
    {$ELSE}
    LIBEV_NAME = 'libev.so.4';
    {$ENDIF}
  {$ENDIF}

  // Versión de libev
  LIBEV_VERSION_MAJOR = 4;
  LIBEV_VERSION_MINOR = 33;

  // Máscaras de eventos
  EV_NONE     = $00;
  EV_READ     = $01;
  EV_WRITE    = $02;
  EV_IO       = EV_READ;
  EV_TIMER    = $00000100;
  EV_PERIODIC = $00000200;
  EV_SIGNAL   = $00000400;
  EV_CHILD    = $00000800;
  EV_STAT     = $00001000;
  EV_IDLE     = $00002000;
  EV_PREPARE  = $00004000;
  EV_CHECK    = $00008000;
  EV_EMBED    = $00010000;
  EV_FORK     = $00020000;
  EV_CLEANUP  = $00040000;
  EV_ASYNC    = $00080000;
  EV_CUSTOM   = $01000000;
  EV_ERROR    = cint($80000000);

  // Flags para ev_run
  EVRUN_NOWAIT = 1;
  EVRUN_ONCE   = 2;

  // Flags para ev_break
  EVBREAK_CANCEL = 0;
  EVBREAK_ONE    = 1;
  EVBREAK_ALL    = 2;

  // Flags para ev_default_loop
  EVFLAG_AUTO       = $00000000;
  EVFLAG_NOENV      = $01000000;
  EVFLAG_FORKCHECK  = $02000000;
  EVFLAG_NOINOTIFY  = $00100000;
  EVFLAG_SIGNALFD   = $00200000;
  EVFLAG_NOSIGMASK  = $00400000;
  EVFLAG_NOTIMERFD  = $00800000;

  // Backends disponibles
  EVBACKEND_SELECT   = $00000001;
  EVBACKEND_POLL     = $00000002;
  EVBACKEND_EPOLL    = $00000004;
  EVBACKEND_KQUEUE   = $00000008;
  EVBACKEND_DEVPOLL  = $00000010;
  EVBACKEND_PORT     = $00000020;
  EVBACKEND_LINUXAIO = $00000040;
  EVBACKEND_IOURING  = $00000080;
  EVBACKEND_ALL      = $000000FF;

type
  // Tipos básicos
  ev_tstamp = cdouble;
  TEvLoop = record end;
  PEvLoop = ^TEvLoop;

  // Callback para watchers
  TEvCallback = procedure(loop: PEvLoop; w: Pointer; revents: cint); cdecl;

  // Estructura base de watcher
  PEvWatcher = ^TEvWatcher;
  TEvWatcher = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
  end;

  // Watcher con lista enlazada
  PEvWatcherList = ^TEvWatcherList;
  TEvWatcherList = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    next: PEvWatcherList;
  end;

  // Watcher con tiempo
  PEvWatcherTime = ^TEvWatcherTime;
  TEvWatcherTime = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    at: ev_tstamp;
  end;

  // Watcher I/O
  PEvIo = ^TEvIo;
  TEvIo = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    next: PEvWatcherList;
    fd: cint;
    events: cint;
  end;

  // Timer
  PEvTimer = ^TEvTimer;
  TEvTimer = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    at: ev_tstamp;
    repeat_: ev_tstamp;
  end;

  // Callback para periodic reschedule
  TEvPeriodicRescheduleCallback = function(w: PEvWatcherTime; now: ev_tstamp): ev_tstamp; cdecl;

  // Timer periódico
  PEvPeriodic = ^TEvPeriodic;
  TEvPeriodic = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    at: ev_tstamp;
    offset: ev_tstamp;
    interval: ev_tstamp;
    reschedule_cb: TEvPeriodicRescheduleCallback;
  end;

  // Signal watcher
  PEvSignal = ^TEvSignal;
  TEvSignal = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    next: PEvWatcherList;
    signum: cint;
  end;

  // Child watcher
  PEvChild = ^TEvChild;
  TEvChild = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    next: PEvWatcherList;
    flags: cint;
    pid: cint;
    rpid: cint;
    rstatus: cint;
  end;

  // Idle watcher
  PEvIdle = ^TEvIdle;
  TEvIdle = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
  end;

  // Prepare watcher
  PEvPrepare = ^TEvPrepare;
  TEvPrepare = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
  end;

  // Check watcher
  PEvCheck = ^TEvCheck;
  TEvCheck = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
  end;

  // Fork watcher
  PEvFork = ^TEvFork;
  TEvFork = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
  end;

  // Cleanup watcher
  PEvCleanup = ^TEvCleanup;
  TEvCleanup = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
  end;

  // Async watcher
  PEvAsync = ^TEvAsync;
  TEvAsync = record
    active: cint;
    pending: cint;
    priority: cint;
    data: Pointer;
    cb: TEvCallback;
    sent: cint; // volatile
  end;

var
  // Handle de la librería
  LibHandle: TLibHandle = 0;

// Funciones wrapper que llaman a la librería dinámica
function ev_version_major: cint;
function ev_version_minor: cint;
function ev_supported_backends: cuint;
function ev_recommended_backends: cuint;
function ev_embeddable_backends: cuint;
function ev_time: ev_tstamp;
procedure ev_sleep(delay: ev_tstamp);

function ev_default_loop(flags: cuint): PEvLoop;
function ev_loop_new(flags: cuint): PEvLoop;
procedure ev_loop_destroy(loop: PEvLoop);
procedure ev_loop_fork(loop: PEvLoop);
function ev_now(loop: PEvLoop): ev_tstamp;
procedure ev_now_update(loop: PEvLoop);
function ev_backend(loop: PEvLoop): cuint;

function ev_run(loop: PEvLoop; flags: cint): cint;
procedure ev_break(loop: PEvLoop; how: cint);
procedure ev_ref(loop: PEvLoop);
procedure ev_unref(loop: PEvLoop);

procedure ev_io_start(loop: PEvLoop; w: PEvIo);
procedure ev_io_stop(loop: PEvLoop; w: PEvIo);

procedure ev_timer_start(loop: PEvLoop; w: PEvTimer);
procedure ev_timer_stop(loop: PEvLoop; w: PEvTimer);
procedure ev_timer_again(loop: PEvLoop; w: PEvTimer);
function ev_timer_remaining(loop: PEvLoop; w: PEvTimer): ev_tstamp;

procedure ev_signal_start(loop: PEvLoop; w: PEvSignal);
procedure ev_signal_stop(loop: PEvLoop; w: PEvSignal);

procedure ev_child_start(loop: PEvLoop; w: PEvChild);
procedure ev_child_stop(loop: PEvLoop; w: PEvChild);

procedure ev_idle_start(loop: PEvLoop; w: PEvIdle);
procedure ev_idle_stop(loop: PEvLoop; w: PEvIdle);

procedure ev_prepare_start(loop: PEvLoop; w: PEvPrepare);
procedure ev_prepare_stop(loop: PEvLoop; w: PEvPrepare);

procedure ev_check_start(loop: PEvLoop; w: PEvCheck);
procedure ev_check_stop(loop: PEvLoop; w: PEvCheck);

procedure ev_async_start(loop: PEvLoop; w: PEvAsync);
procedure ev_async_stop(loop: PEvLoop; w: PEvAsync);
procedure ev_async_send(loop: PEvLoop; w: PEvAsync);

procedure ev_feed_event(loop: PEvLoop; w: Pointer; revents: cint);
procedure ev_feed_fd_event(loop: PEvLoop; fd: cint; revents: cint);
procedure ev_invoke(loop: PEvLoop; w: Pointer; revents: cint);
function ev_clear_pending(loop: PEvLoop; w: Pointer): cint;

// Funciones de conveniencia para inicialización
procedure ev_init(w: PEvWatcher; cb: TEvCallback; priority: cint = 0);
procedure ev_io_init(w: PEvIo; cb: TEvCallback; fd: cint; events: cint);
procedure ev_timer_init(w: PEvTimer; cb: TEvCallback; after: ev_tstamp; repeat_: ev_tstamp);
procedure ev_signal_init(w: PEvSignal; cb: TEvCallback; signum: cint);
procedure ev_child_init(w: PEvChild; cb: TEvCallback; pid: cint; trace: Boolean);
procedure ev_idle_init(w: PEvIdle; cb: TEvCallback);
procedure ev_prepare_init(w: PEvPrepare; cb: TEvCallback);
procedure ev_check_init(w: PEvCheck; cb: TEvCallback);
procedure ev_async_init(w: PEvAsync; cb: TEvCallback);

// Macros útiles como funciones
function ev_is_pending(w: PEvWatcher): Boolean;
function ev_is_active(w: PEvWatcher): Boolean;
procedure ev_set_priority(w: PEvWatcher; priority: cint);
function ev_priority(w: PEvWatcher): cint;

// Funciones de carga y descarga de la librería
function LoadLibEv: Boolean;
procedure UnloadLibEv;
function IsLibEvLoaded: Boolean;

implementation

uses
  SysUtils;

// Tipos de función para llamadas dinámicas
type
  Tev_version_func = function(): cint; cdecl;
  Tev_supported_backends_func = function(): cuint; cdecl;
  Tev_time_func = function(): ev_tstamp; cdecl;
  Tev_sleep_proc = procedure(delay: ev_tstamp); cdecl;
  Tev_default_loop_func = function(flags: cuint): PEvLoop; cdecl;
  Tev_loop_new_func = function(flags: cuint): PEvLoop; cdecl;
  Tev_loop_destroy_proc = procedure(loop: PEvLoop); cdecl;
  Tev_loop_fork_proc = procedure(loop: PEvLoop); cdecl;
  Tev_now_func = function(loop: PEvLoop): ev_tstamp; cdecl;
  Tev_now_update_proc = procedure(loop: PEvLoop); cdecl;
  Tev_backend_func = function(loop: PEvLoop): cuint; cdecl;
  Tev_run_func = function(loop: PEvLoop; flags: cint): cint; cdecl;
  Tev_break_proc = procedure(loop: PEvLoop; how: cint); cdecl;
  Tev_ref_proc = procedure(loop: PEvLoop); cdecl;
  Tev_io_start_proc = procedure(loop: PEvLoop; w: PEvIo); cdecl;
  Tev_io_stop_proc = procedure(loop: PEvLoop; w: PEvIo); cdecl;
  Tev_timer_start_proc = procedure(loop: PEvLoop; w: PEvTimer); cdecl;
  Tev_timer_stop_proc = procedure(loop: PEvLoop; w: PEvTimer); cdecl;
  Tev_timer_again_proc = procedure(loop: PEvLoop; w: PEvTimer); cdecl;
  Tev_timer_remaining_func = function(loop: PEvLoop; w: PEvTimer): ev_tstamp; cdecl;

function LoadLibEv: Boolean;
begin
  Result := False;
  if LibHandle <> 0 then
  begin
    Result := True;
    Exit;
  end;

  LibHandle := LoadLibrary(LIBEV_NAME);
  Result := LibHandle <> 0;
end;

procedure UnloadLibEv;
begin
  if LibHandle <> 0 then
  begin
    FreeLibrary(LibHandle);
    LibHandle := 0;
  end;
end;

function IsLibEvLoaded: Boolean;
begin
  Result := LibHandle <> 0;
end;

// Implementación de funciones wrapper
function ev_version_major: cint;
var
  func: Tev_version_func;
begin
  if LibHandle <> 0 then
  begin
    func := Tev_version_func(GetProcAddress(LibHandle, 'ev_version_major'));
    if Assigned(func) then
      Result := func()
    else
      Result := LIBEV_VERSION_MAJOR;
  end
  else
    Result := LIBEV_VERSION_MAJOR;
end;

function ev_version_minor: cint;
var
  func: Tev_version_func;
begin
  if LibHandle <> 0 then
  begin
    func := Tev_version_func(GetProcAddress(LibHandle, 'ev_version_minor'));
    if Assigned(func) then
      Result := func()
    else
      Result := LIBEV_VERSION_MINOR;
  end
  else
    Result := LIBEV_VERSION_MINOR;
end;

function ev_supported_backends: cuint;
var
  func: Tev_supported_backends_func;
begin
  func := Tev_supported_backends_func(GetProcAddress(LibHandle, 'ev_supported_backends'));
  if Assigned(func) then
    Result := func()
  else
    Result := 0;
end;

function ev_recommended_backends: cuint;
var
  func: Tev_supported_backends_func;
begin
  func := Tev_supported_backends_func(GetProcAddress(LibHandle, 'ev_recommended_backends'));
  if Assigned(func) then
    Result := func()
  else
    Result := 0;
end;

function ev_embeddable_backends: cuint;
var
  func: Tev_supported_backends_func;
begin
  func := Tev_supported_backends_func(GetProcAddress(LibHandle, 'ev_embeddable_backends'));
  if Assigned(func) then
    Result := func()
  else
    Result := 0;
end;

function ev_time: ev_tstamp;
var
  func: Tev_time_func;
begin
  func := Tev_time_func(GetProcAddress(LibHandle, 'ev_time'));
  if Assigned(func) then
    Result := func()
  else
    Result := 0.0;
end;

procedure ev_sleep(delay: ev_tstamp);
var
  proc_: Tev_sleep_proc;
begin
  proc_ := Tev_sleep_proc(GetProcAddress(LibHandle, 'ev_sleep'));
  if Assigned(proc_) then
    proc_(delay);
end;

function ev_default_loop(flags: cuint): PEvLoop;
var
  func: Tev_default_loop_func;
begin
  func := Tev_default_loop_func(GetProcAddress(LibHandle, 'ev_default_loop'));
  if Assigned(func) then
    Result := func(flags)
  else
    Result := nil;
end;

function ev_loop_new(flags: cuint): PEvLoop;
var
  func: Tev_loop_new_func;
begin
  func := Tev_loop_new_func(GetProcAddress(LibHandle, 'ev_loop_new'));
  if Assigned(func) then
    Result := func(flags)
  else
    Result := nil;
end;

procedure ev_loop_destroy(loop: PEvLoop);
var
  proc_: Tev_loop_destroy_proc;
begin
  proc_ := Tev_loop_destroy_proc(GetProcAddress(LibHandle, 'ev_loop_destroy'));
  if Assigned(proc_) then
    proc_(loop);
end;

procedure ev_loop_fork(loop: PEvLoop);
var
  proc_: Tev_loop_fork_proc;
begin
  proc_ := Tev_loop_fork_proc(GetProcAddress(LibHandle, 'ev_loop_fork'));
  if Assigned(proc_) then
    proc_(loop);
end;

function ev_now(loop: PEvLoop): ev_tstamp;
var
  func: Tev_now_func;
begin
  func := Tev_now_func(GetProcAddress(LibHandle, 'ev_now'));
  if Assigned(func) then
    Result := func(loop)
  else
    Result := 0.0;
end;

procedure ev_now_update(loop: PEvLoop);
var
  proc_: Tev_now_update_proc;
begin
  proc_ := Tev_now_update_proc(GetProcAddress(LibHandle, 'ev_now_update'));
  if Assigned(proc_) then
    proc_(loop);
end;

function ev_backend(loop: PEvLoop): cuint;
var
  func: Tev_backend_func;
begin
  func := Tev_backend_func(GetProcAddress(LibHandle, 'ev_backend'));
  if Assigned(func) then
    Result := func(loop)
  else
    Result := 0;
end;

function ev_run(loop: PEvLoop; flags: cint): cint;
var
  func: Tev_run_func;
begin
  func := Tev_run_func(GetProcAddress(LibHandle, 'ev_run'));
  if Assigned(func) then
    Result := func(loop, flags)
  else
    Result := 0;
end;

procedure ev_break(loop: PEvLoop; how: cint);
var
  proc_: Tev_break_proc;
begin
  proc_ := Tev_break_proc(GetProcAddress(LibHandle, 'ev_break'));
  if Assigned(proc_) then
    proc_(loop, how);
end;

procedure ev_ref(loop: PEvLoop);
var
  proc_: Tev_ref_proc;
begin
  proc_ := Tev_ref_proc(GetProcAddress(LibHandle, 'ev_ref'));
  if Assigned(proc_) then
    proc_(loop);
end;

procedure ev_unref(loop: PEvLoop);
var
  proc_: Tev_ref_proc;
begin
  proc_ := Tev_ref_proc(GetProcAddress(LibHandle, 'ev_unref'));
  if Assigned(proc_) then
    proc_(loop);
end;

procedure ev_io_start(loop: PEvLoop; w: PEvIo);
var
  proc_: Tev_io_start_proc;
begin
  proc_ := Tev_io_start_proc(GetProcAddress(LibHandle, 'ev_io_start'));
  if Assigned(proc_) then
    proc_(loop, w);
end;

procedure ev_io_stop(loop: PEvLoop; w: PEvIo);
var
  proc_: Tev_io_stop_proc;
begin
  proc_ := Tev_io_stop_proc(GetProcAddress(LibHandle, 'ev_io_stop'));
  if Assigned(proc_) then
    proc_(loop, w);
end;

procedure ev_timer_start(loop: PEvLoop; w: PEvTimer);
var
  proc_: Tev_timer_start_proc;
begin
  proc_ := Tev_timer_start_proc(GetProcAddress(LibHandle, 'ev_timer_start'));
  if Assigned(proc_) then
    proc_(loop, w);
end;

procedure ev_timer_stop(loop: PEvLoop; w: PEvTimer);
var
  proc_: Tev_timer_stop_proc;
begin
  proc_ := Tev_timer_stop_proc(GetProcAddress(LibHandle, 'ev_timer_stop'));
  if Assigned(proc_) then
    proc_(loop, w);
end;

procedure ev_timer_again(loop: PEvLoop; w: PEvTimer);
var
  proc_: Tev_timer_again_proc;
begin
  proc_ := Tev_timer_again_proc(GetProcAddress(LibHandle, 'ev_timer_again'));
  if Assigned(proc_) then
    proc_(loop, w);
end;

function ev_timer_remaining(loop: PEvLoop; w: PEvTimer): ev_tstamp;
var
  func: Tev_timer_remaining_func;
begin
  func := Tev_timer_remaining_func(GetProcAddress(LibHandle, 'ev_timer_remaining'));
  if Assigned(func) then
    Result := func(loop, w)
  else
    Result := 0.0;
end;

// Stubs para otras funciones (implementa según necesites)
procedure ev_signal_start(loop: PEvLoop; w: PEvSignal);
begin
  // Implementar si es necesario
end;

procedure ev_signal_stop(loop: PEvLoop; w: PEvSignal);
begin
  // Implementar si es necesario
end;

procedure ev_child_start(loop: PEvLoop; w: PEvChild);
begin
  // Implementar si es necesario
end;

procedure ev_child_stop(loop: PEvLoop; w: PEvChild);
begin
  // Implementar si es necesario
end;

procedure ev_idle_start(loop: PEvLoop; w: PEvIdle);
begin
  // Implementar si es necesario
end;

procedure ev_idle_stop(loop: PEvLoop; w: PEvIdle);
begin
  // Implementar si es necesario
end;

procedure ev_prepare_start(loop: PEvLoop; w: PEvPrepare);
begin
  // Implementar si es necesario
end;

procedure ev_prepare_stop(loop: PEvLoop; w: PEvPrepare);
begin
  // Implementar si es necesario
end;

procedure ev_check_start(loop: PEvLoop; w: PEvCheck);
begin
  // Implementar si es necesario
end;

procedure ev_check_stop(loop: PEvLoop; w: PEvCheck);
begin
  // Implementar si es necesario
end;

procedure ev_async_start(loop: PEvLoop; w: PEvAsync);
begin
  // Implementar si es necesario
end;

procedure ev_async_stop(loop: PEvLoop; w: PEvAsync);
begin
  // Implementar si es necesario
end;

procedure ev_async_send(loop: PEvLoop; w: PEvAsync);
begin
  // Implementar si es necesario
end;

procedure ev_feed_event(loop: PEvLoop; w: Pointer; revents: cint);
begin
  // Implementar si es necesario
end;

procedure ev_feed_fd_event(loop: PEvLoop; fd: cint; revents: cint);
begin
  // Implementar si es necesario
end;

procedure ev_invoke(loop: PEvLoop; w: Pointer; revents: cint);
begin
  // Implementar si es necesario
end;

function ev_clear_pending(loop: PEvLoop; w: Pointer): cint;
begin
  Result := 0;
  // Implementar si es necesario
end;

// Implementación de las funciones de conveniencia
procedure ev_init(w: PEvWatcher; cb: TEvCallback; priority: cint);
begin
  w^.active := 0;
  w^.pending := 0;
  w^.priority := priority;
  w^.cb := cb;
end;

procedure ev_io_init(w: PEvIo; cb: TEvCallback; fd: cint; events: cint);
begin
  ev_init(PEvWatcher(w), cb);
  w^.fd := fd;
  w^.events := events;
end;

procedure ev_timer_init(w: PEvTimer; cb: TEvCallback; after: ev_tstamp; repeat_: ev_tstamp);
begin
  ev_init(PEvWatcher(w), cb);
  w^.at := after;
  w^.repeat_ := repeat_;
end;

procedure ev_signal_init(w: PEvSignal; cb: TEvCallback; signum: cint);
begin
  ev_init(PEvWatcher(w), cb);
  w^.signum := signum;
end;

procedure ev_child_init(w: PEvChild; cb: TEvCallback; pid: cint; trace: Boolean);
begin
  ev_init(PEvWatcher(w), cb);
  w^.pid := pid;
  w^.flags := Ord(trace);
end;

procedure ev_idle_init(w: PEvIdle; cb: TEvCallback);
begin
  ev_init(PEvWatcher(w), cb);
end;

procedure ev_prepare_init(w: PEvPrepare; cb: TEvCallback);
begin
  ev_init(PEvWatcher(w), cb);
end;

procedure ev_check_init(w: PEvCheck; cb: TEvCallback);
begin
  ev_init(PEvWatcher(w), cb);
end;

procedure ev_async_init(w: PEvAsync; cb: TEvCallback);
begin
  ev_init(PEvWatcher(w), cb);
  w^.sent := 0;
end;

function ev_is_pending(w: PEvWatcher): Boolean;
begin
  Result := w^.pending <> 0;
end;

function ev_is_active(w: PEvWatcher): Boolean;
begin
  Result := w^.active <> 0;
end;

procedure ev_set_priority(w: PEvWatcher; priority: cint);
begin
  w^.priority := priority;
end;

function ev_priority(w: PEvWatcher): cint;
begin
  Result := w^.priority;
end;

initialization
  // Intentar cargar la librería al inicializar el unit
  LoadLibEv;

finalization
  // Descargar la librería al finalizar
  UnloadLibEv;

end.
