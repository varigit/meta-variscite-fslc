SRC_URI := "${@d.getVar('SRC_URI').replace('git://git.tartarus.org/simon/puzzles.git ', 'git://git.tartarus.org/simon/puzzles.git;branch=main')}"
