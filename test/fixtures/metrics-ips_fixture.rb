def ipcs_answer
  <<-TEXT

    ------ Messages Status --------
    allocated queues = 0
    used headers = 0
    used space = 0 bytes

    ------ Shared Memory Status --------
    segments allocated 31
    pages allocated 52233
    pages resident  16915
    pages swapped   0
    Swap performance: 0 attempts	 0 successes

    ------ Semaphore Status --------
    used arrays = 0
    allocated semaphores = 0

  TEXT
end
