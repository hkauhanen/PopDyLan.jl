using PopDyLan
id = ARGS[1]

function do_chebyshev_stuff(de::Float64)
  com = ChebyshevCommunity(5, de)#, 2)
  no_speakers = 50

  for i in 1:no_speakers
    inject!(MomentumSelector(0.1, 0.4, 2.0, 2, 0.1), com)
  end

  char = 0.5
  while ((char > 0.01) & (char < 0.99)) & (com.interactions < no_speakers^2*100_000)
    rendezvous!(com)
    char = characterize(com)
  end

  char
end

Threads.@threads for rep in 1:1
  open("res/res.$id.$rep.csv", "w") do f
    write(f, "jobid,rep,subrep,de,x\n")
    for subrep in 1:1000
      res1 = do_chebyshev_stuff(0.0)
      res2 = do_chebyshev_stuff(1.0)
      res3 = do_chebyshev_stuff(5.0)
      write(f, "$id,$rep,$subrep,0.0,$res1\n")
      write(f, "$id,$rep,$subrep,1.0,$res2\n")
      write(f, "$id,$rep,$subrep,5.0,$res3\n")
    end
  end
end
