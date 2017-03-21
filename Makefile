LOAD_PATH = \
	ebin \
	deps/*/ebin \
	$(NULL)

NODE = one@127.0.0.1
#NODE=$(shell cat ./config/node_name.conf)
RANDOM_VAL=$(shell od -An -N1 -i /dev/random | head -1 | awk '{print $$1}' )

ifeq ($(NODE),)
	NODE = ptest@127.0.0.1
endif

SED_CMD=sed -i '.bak' 's/dict/dict:dict/g' src/simple_types.hrl
COOKIE=4SZe3DECXwAdHbz0Yzm7rWrc5AG0MjiSs90WGgsfXJ3Mx0tLuEXtfa9ud3ZOOSQ
MASH_NODE=mash_$(RANDOM_VAL)_$(NODE)
# 部分配置参数
OPTS = \
	-pa $(LOAD_PATH) \
	-kernel error_logger '{file, "log/error.log"}' \
	-env ERL_MAX_ETS_TABLES 10000 \
	-setcookie $(COOKIE) \
	+A 4 +K true +P 120000   \
	-smp enable \
	-kernel inet_dist_listen_min 48808 \
	inet_dist_listen_max 48988 \
#	-detached  \
	-noshell \
	$(NULL)

# erl_call
ERL_CALL=erl_call -c $(COOKIE) -name $(NODE) -e

THRIFT= ./bin/thrift
# rebar-用于编译
REBAR := ./bin/rebar --config config/rebar.config
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
REBAR := ./bin/rebar.linux --config config/rebar.config
# do something Linux-y
endif

# 编译全部
all:compile
	true

# 获取到所有的依赖
deps:
	$(REBAR) get-deps

# 编译全部
compile:
	$(REBAR) compile

#进入erlang shell
erl:
	erl $(OPTS)


s:
	erl $(OPTS)  -name $(NODE) -eval "application:start(ptest)" -hidden

start:
	erl $(OPTS)  -detached -name $(NODE) -eval "application:start(ptest)" -hidden


stop:
	echo "ptest_app:stop()." | \
	$(ERL_CALL)
	-$(ERL_CALL) -q


# 连接上后台erlang节点
remsh:
	erl $(OPTS) -name $(MASH_NODE)  -remsh $(NODE) -hidden

mkserver:
	$(REBAR) create template=simplesrv srvid=src/$(SNAME)

g:
	$(THRIFT) -gen erl -out src thrift/simple.thrift

	$(SED_CMD)
	

.PHONY:deps
