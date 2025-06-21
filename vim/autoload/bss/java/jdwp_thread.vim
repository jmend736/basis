
""
" Defines and starts the asyncio thread.
"
function! bss#java#jdwp_thread#Init() abort
python3 << trim END
  import threading
  import asyncio
  import queue

  class AioThread(threading.Thread):

    def __init__(self):
      super().__init__(daemon=True)
      self.loop = asyncio.new_event_loop()
      self.pending    = set()         # Pending futures
      self.arrivals   = queue.Queue() # Unprocessed packets that arrived
      self.departures = queue.Queue() # Unprocessed packets that will depart

    def run(self):
      asyncio.set_event_loop(self.loop)
      self.loop.run_forever()

    def close(self):
      self.loop.call_soon_threadsafe(self.loop.stop)
      self.join()

    def co_submit(self, coro):
      conc_future = asyncio.run_coroutine_threadsafe(coro, self.loop)
      self.pending.add(conc_future)
      conc_future.add_done_callback(self.co_submit_done)
      return conc_future

    def co_submit_done(self, f):
      self.pending.discard(f)
      try:
        f.result()
      except Exception as ex:
        print(ex)

  AT = AioThread()
  AT.start()
END
endfunction

""
" Attempts to kill the asyncio thread.
"
function! bss#java#jdwp_thread#Close() abort
python3 << trim END
  try:
    AT.close()
  except NameError as ex:
    pass
END
endfunction
