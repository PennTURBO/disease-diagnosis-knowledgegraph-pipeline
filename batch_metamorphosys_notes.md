Follow the [BatchMetaMorphoSys](https://www.nlm.nih.gov/research/umls/implementation_resources/community/mmsys/BatchMetaMorphoSys.html) directions  to programmatically create _RRF_ files from the desired UMLS sources.

`cat` the BatchMetaMorphoSys bash script to `metamorphosys_batch.sh` and edit as necessary. For example:

```BASH
    #!/bin/sh -f
    # Specify directory containing .RRF or .nlm files
    METADIR=/terabytes/2019AB-full/
    # Specify output directory
    DESTDIR=/terabytes/2019AB_selected
    # Specify MetamorphoSys directory
    MMSYS_HOME=/terabytes/2019AB-full/
    # Specify CLASSPATH
    CLASSPATH=${MMSYS_HOME}:$MMSYS_HOME/lib/jpf-boot.jar
    # Specify JAVA_HOME
    JAVA_HOME=$MMSYS_HOME/jre/linux
    # Specify configuration file
    CONFIG_FILE=/terabytes/2019AB_selected.prop
    # Run Batch MetamorphoSys
    export METADIR
    export DESTDIR
    export MMSYS_HOME
    export CLASSPATH
    export JAVA_HOME
    cd $MMSYS_HOME
    $JAVA_HOME/bin/java -Djava.awt.headless=true -Djpf.boot.config=$MMSYS_HOME/etc/subset.boot.properties \
    -Dlog4j.configuration=$MMSYS_HOME/etc/subset.log4j.properties -Dinput.uri=$METADIR \
    -Doutput.uri=$DESTDIR -Dmmsys.config.uri=$CONFIG_FILE -Xms300M -Xmx1000M org.java.plugin.boot.Boot
```

Then create or edit the properties file if necessary, especially enabling or disabling sources. Enabled sources are values of the `selected_sources` property. A [sample properties file](metamorphosys_snomed_sample.prop) is included in the root of this repository.

Run chmod to make the shell script executable, if necessary. Then start creating the _RRF_ files:

```BASH
$ ./metamorphosys_batch.sh
```

