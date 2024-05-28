===================================================================================
Boot Linux Kernel with boot-wrapper-aarch64 with Arm FVP Base_RevC_AEMvA
===================================================================================

Download toolchain and Base RevC FVP 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make download

Clone Linux and boot-wrapper-aarch64 source
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make clone 


Configure Linux and boot-wrapper-aarch64 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make config 

Build linux and boot-wrapper-aarch64 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make  build

Build the rootfs 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make  buildfs


Run FVP 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh 

    make  run 

Debug FVP with Arm DS  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You need import the Base RevC FVP to the Arm DS before debug. And then type: 

.. code-block:: sh 

    make  debug 

