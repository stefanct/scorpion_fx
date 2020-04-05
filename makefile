FN?=200

MUD_TARGETS := mud_back-right.stl mud_back-left.stl mud_front-right.stl mud_front-left.stl

TARGETS = $(MUD_TARGETS) bike.stl beam.stl
TARGETS := $(foreach t,$(TARGETS),$(patsubst %.stl,%-norm_infill.stl,$(t)) $(patsubst %.stl,%-high_infill.stl,$(t)))
# MAKEFLAGS := $(MAKEFLAGS) -j

all: $(TARGETS)

$(TARGETS): *.scad
	openscad -D '$$fn=$(FN)' -D is_left=$(if $(findstring left,$@),1,0) -D is_high_infill=$(if $(findstring high_infill,$@),1,0) $(firstword $(subst -, ,$@)).scad -o $@

define LAUNCH
#!/bin/sh

if [ ! -f $$0.stl ]; then
  echo "$$0.stl does not exist!"
  exit 1
fi

openscad -D "file=\"$$0.stl\"" launch.scad
endef
export LAUNCH

define FILE
import(file);
endef
export FILE

launch.scad:
	echo "$$FILE" > $@

launch.sh: launch.scad
	echo "$$LAUNCH" >$(@:%.stl=)
	chmod +x $@

symlinks: launch.sh
	$(foreach t,$(TARGETS),ln -fs launch.sh $(t:%.stl=%);)

clean:
	rm -f *.stl *.png launch.*
	find -lname launch.sh -delete

.PHONY: all clean symlinks
