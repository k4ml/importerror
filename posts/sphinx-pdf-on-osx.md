<!-- 
.. title: Generating Sphinx PDF on MacOS X
.. slug: sphinx-pdf-on-osx
.. date: 2015/08/31 10:48:01
.. tags: sphinx, rst, latex, pdflatex, pdf
.. link: 
.. description: Generating PDF for Sphinx documentation tools on MacOS X
.. type: text
-->

Latex distribution is known to be very big on any platform. The MacTex package is 2.5GB download. Fortunately there's a minimal package, BasicTex which is around 100MB. That's perfect and seem to include all needed for Sphinx to generate the pdf.

But after running `make latexpdf` in my Sphinx doc, got errors about missing sty.

    ! LaTeX Error: File `wrapfig.sty' not found.
    
    Type X to quit or <RETURN> to proceed,
    or enter new name. (Default extension: sty)
    
Searching around, lot of solutions mention about install `texlive-late-extra` package (on Debian/Ubuntu). Until I found that TexLive also has a packages manager called `tlmgr`. First attempt of running `tlmgr` complain about itself require an update:-

    sudo tlmgr update --self

After that I need to install the following packages:-

    sudo tlmgr install titlesec framed threeparttable wrapfig multirow collection-fontsrecommended

And Sphinx successfully generated the PDF.
