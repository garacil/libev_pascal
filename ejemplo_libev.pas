(*
  Autor: Germán Luis Aracil Boned
  Email: garacilb@gmail.com
  Proyecto: Binding Pascal para libev
  Descripción: Este archivo forma parte de un proyecto para utilizar la biblioteca libev desde Free Pascal.
  Fecha: 2025
*)

program ejemplo_libev;

{$mode objfpc}{$H+}

uses
  libev, ctypes, sysutils;

var
  loop: PEvLoop;
  timer_watcher: TEvTimer;
  io_watcher: TEvIo;
  timer_count: Integer = 0;

// Callback para el timer
procedure timer_callback(loop: PEvLoop; w: Pointer; revents: cint); cdecl;
begin
  Inc(timer_count);
  WriteLn('Timer disparado #', timer_count, ' a las ', TimeToStr(Now));
  // Parar el loop después de 3 disparos
  if timer_count >= 3 then
  begin
    WriteLn('Parando el loop...');
    ev_break(loop, EVBREAK_ALL);
  end;
end;

// Callback para entrada estándar
procedure stdin_callback(loop: PEvLoop; w: Pointer; revents: cint); cdecl;
var
  input: string;
begin
  if (revents and EV_READ) <> 0 then
  begin
    WriteLn('Datos disponibles en stdin');
    ReadLn(input);
    WriteLn('Leído: ', input);
    
    if LowerCase(input) = 'quit' then
    begin
      WriteLn('Saliendo...');
      ev_break(loop, EVBREAK_ALL);
    end;
  end;
end;

begin
  // Verificar que la librería se cargó correctamente
  if not IsLibEvLoaded then
  begin
    WriteLn('Error: No se pudo cargar libev');
    WriteLn('Asegúrate de que ', LIBEV_NAME, ' esté instalado');
    Halt(1);
  end;

  // Mostrar información de la versión
  WriteLn('libev versión: ', ev_version_major(), '.', ev_version_minor());
  WriteLn('Backends soportados: $', IntToHex(ev_supported_backends(), 8));
  WriteLn('Backends recomendados: $', IntToHex(ev_recommended_backends(), 8));

  // Crear el loop por defecto
  loop := ev_default_loop(EVFLAG_AUTO);
  if loop = nil then
  begin
    WriteLn('Error: No se pudo crear el loop de eventos');
    Halt(1);
  end;

  WriteLn('Backend en uso: $', IntToHex(ev_backend(loop), 8));

  // Configurar un timer que se ejecute cada segundo
  ev_timer_init(@timer_watcher, @timer_callback, 1.0, 1.0);
  ev_timer_start(loop, @timer_watcher);

  // Configurar un watcher para la entrada estándar
  ev_io_init(@io_watcher, @stdin_callback, 0, EV_READ); // fd 0 = stdin
  ev_io_start(loop, @io_watcher);

  WriteLn('Loop de eventos iniciado');
  WriteLn('- El timer se ejecutará cada segundo');
  WriteLn('- Puedes escribir texto y presionar Enter');
  WriteLn('- Escribe "quit" para salir');
  WriteLn('- El programa terminará automáticamente después de 3 disparos del timer');
  WriteLn;

  // Ejecutar el loop principal
  try
    ev_run(loop, 0);
  except
    on E: Exception do
      WriteLn('Error en el loop: ', E.Message);
  end;

  // Limpiar
  ev_timer_stop(loop, @timer_watcher);
  ev_io_stop(loop, @io_watcher);
  
  WriteLn('Programa terminado');
end.
