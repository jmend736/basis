
let s:commands = {}

function! bss#java#jdwp#Init() abort
  command!
        \ -nargs=1
        \ -complete=customlist,bss#java#jdwp#Complete
        \ Jdwp
        \ call s:commands[<q-args>]()
endfunction

function! bss#java#jdwp#Complete(arg, cmd, cur) abort
  return s:commands->keys()->filter({k, v -> v =~ '^' .. a:arg})
endfunction

function! s:commands.init() abort dict
  call self.run_imports()
  call self.kill()
  call self.at_start()
  call self.reload()
endfunction

function! s:commands.run_imports() abort dict
python3 << trim END
  import struct
  import asyncio
  import time
  from concurrent.futures import ThreadPoolExecutor
  from threading import Condition, Thread
  from dataclasses import dataclass
END
endfunction

function! s:commands.at_define() abort
python3 << trim END
  class AsyncThread(Thread):
    _instance = None

    def __init__(self):
      super().__init__(daemon=True)
      self.loop = asyncio.new_event_loop()

    def run(self):
      asyncio.set_event_loop(self.loop)
      self.loop.run_forever()

    def stop(self):
      self.loop.call_soon_threadsafe(self.loop.stop)
      self.join()

    def submit(self, coro):
      return asyncio.run_coroutine_threadsafe(coro, self.loop)
END
endfunction

function! s:commands.at_start() abort
  call self.at_define()
python3 << trim END
  AsyncThread._instance = AsyncThread()
  AsyncThread._instance.start()
END
endfunction

function! s:commands.at_stop() abort
python3 << trim END
  if AsyncThread._instance != None:
    AsyncThread._instance.stop()
END
endfunction

function! s:commands.at_dump() abort
python3 << trim END
  print(AsyncThread._instance)
END
endfunction

function! s:commands.data_define() abort dict
python3 << trim END
  @dataclass
  class PacketHeader:
    length: int
    pid: int
    flags: int

    def is_cmd(self):
      return not (self.flags & 0x80)

    def content_length(self):
      return self.length - 11

  @dataclass
  class CommandPacket:
    hdr: PacketHeader
    command_set: int
    command: int
    content: bytes

  @dataclass
  class ReplyPacket:
    hdr: PacketHeader
    error_code: int
    content: bytes
END
endfunction

function! s:commands.man_define() abort dict
python3 << trim END
  class Manager:

    _instance = None

    @classmethod
    def get(cls):
      if cls._instance is None:
        cls._instance = Manager()
      return cls._instance

    def run(self):
      return AsyncThread._instance.submit(self.top())

    async def top(self):
      r, w = await asyncio.open_connection('localhost', 8080)
      await self.handle(r, w)

    async def handle(self, reader, writer):
      await self.handle_handshake(reader, writer)

      while True:
        raw_packet = await reader.read(11)
        fields = struct.unpack_from('>IIB', raw_packet)
        hdr = PacketHeader(*fields)
        pkt = None
        if hdr.is_cmd():
          pkt = CommandPacket(
            hdr,
            *struct.unpack_from('>BB', raw_packet, 9),
            await reader.read(hdr.content_length())
          )
          writer.write(struct.pack('>IIBH'), 11, hdr.pid, 0x80)
          await writer.drain()
        else:
          pkt = ReplyPacket(
            hdr,
            *struct.unpack_from('>H', raw_packet, 9),
            await reader.read(hdr.content_length())
          )
        print('pkt :', pkt)

      print('Closing the server')
      writer.close()
      await writer.wait_closed()

    async def handle_handshake(self, reader, writer):
      exp = b'JDWP-Handshake'
      writer.write(exp)
      await writer.drain()
      resp = await reader.read(14)
      if resp != exp:
        raise Exception('Failed handshake!')

END
endfunction

function! s:commands.man_run() abort
python3 << trim END
  f = Manager.get().run()
END
endfunction

function! s:commands.reload() abort dict
  call self.man_define()
  call self.data_define()
endfunction

function! s:commands.kill() abort
python3 << trim END
  try:
    AsyncThread._instance.stop()
  except Exception as e:
    print(e)
END
endfunction

call bss#java#jdwp#Init()
Jdwp init
Jdwp man_run
