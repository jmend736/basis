
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
  call bss#java#jdwp_thread#Init()
  call s:DefineData()
  call s:DefineManager()
endfunction

function! s:commands.kill() abort
  call bss#java#jdwp_thread#Close()
endfunction

function! s:commands.at() abort
python3 << trim END
  print(AT)
END
endfunction

function! s:commands.pending() abort
python3 << trim END
  print('pending:' + ('' if AT.pending else ' <EMPTY>'))
  for p in AT.pending:
    print(f'  {p}')
END
endfunction

function! s:DefineData() abort
python3 << trim END
  from dataclasses import dataclass

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

function! s:DefineManager() abort
python3 << trim END
  import struct
  import asyncio
  import time
  from concurrent.futures import ThreadPoolExecutor
  from threading import Condition, Thread

  class Manager:

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

  AT.co_submit(Manager().top())

END
endfunction

call bss#java#jdwp#Init()
