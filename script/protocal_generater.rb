# -*- coding: utf-8 -*-
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

RecordPath    = "../include/record.hrl"
IndianPath    = "../src/protocal_indian.hrl"
ApiMacroPath  = "../include/api.hrl"
ErrorHeadPath = "../include/error.hrl"
DispacherPath = "../src/protocal_decoder.erl"
EncoderPath   = "../src/protocal_encoder.erl"
ErrorPath     = "../src/protocal_error.erl"

ApiFile       = "../api/api.txt"
PayLoadFile   = "../api/protocal.txt"
ErrorCodeFile = "../api/error_code.txt"

def file_head(desc)
  sprintf("%%%%%% ==================================================================\n%%%%%% %s\n%%%%%% ==================================================================\n\n",
          desc)
end

class Record
  attr_reader :name,:type,:addtion
  def initialize(name,type,addtion=nil)
    @name,@type,@addtion=name,type,addtion
  end

  def default()
    case @type
    when "integer"  then
      "0"
    when "float" then
      "0.0"
    when "double" then
      "0.0"
    when "string" then
      "\"\""
    when "array" then
      "[]"
    when "short" then
      "0"
    when "boolean" then
      "false"
    else
      sprintf("#%s{}",@type)
    end
  end
end

class RStruct
  attr_reader :name
  def initialize(name,desc)
    @name=name
    @records=[]
    @namecap=code_name()
    @desc=desc
  end

  def code_name
    namecap=""
    name.split("_").each do |n|
      namecap+=n.capitalize
    end
    namecap
  end

  def append(record)
    raise "it is not a record!" if record.class!=Record
    @records << record
  end

  def show()
    puts "struct show ===>"
    puts @name
    @records.each do |r|
      puts sprintf("%s %s",r.name,r.type)
    end
  end

  #生成record记录
  def gen_record()
    record_hrl=sprintf("%%%% %s\n",@desc)
    record_hrl+=sprintf("-record(%s, {\n",@name)
    @records.each do |record|
      schema=""
      case record.type
      when "array" then
        schema="list()"
      when "integer" then
        schema=record.type+"()"
      when "short" then
        schema="integer()"
      when "boolean" then
        schema=record.type+"()"
      when "float" then
        schema=record.type+"()"
      when "double" then
        schema="float()"
      when "string" then
        schema=record.type+"()"
      else
        schema=sprintf("#%s{}",record.type)
      end

      record_hrl+= sprintf("          %s = %s :: %s,\n",record.name,record.default,schema)
    end
    record_hrl.chomp!("\n")
    record_hrl.chomp!(",")
    record_hrl+="\n         }).\n\n"
  end

  #生成打包代码
  def gen_encode()
    encode=sprintf("encode_%s(%s = #%s{} ) ->\n",@name, @namecap, @name)
    tail=""
    @records.each do |r|
      case r.type
      when "array"
        encode+= sprintf("  %sBin = encode_array(%s#%s.%s, encode_%s),\n",
                         r.name.capitalize,
                         @namecap,@name,r.name,r.addtion
                         )
      when "struct"
        encode+= sprintf("  %sBin = encode_%s(%s#%s.%s),\n",
                         r.name.capitalize,r.addtion,
                         @namecap,@name,r.name
                         )
      else
        encode+= sprintf("  %sBin = encode_%s(%s#%s.%s),\n",
                         r.name.capitalize,r.type,
                         @namecap,@name,r.name
                         )
      end
      tail+=sprintf("%sBin, ",r.name.capitalize)
    end
    tail.chomp!(" ")
    tail.chomp!(",")
    encode+="  list_to_binary([%s]).\n"%(tail)
    encode
  end


  #生成解包函数
  def gen_decode()
    decode=sprintf("decode_%s(<<Data/binary>>) ->\n",@name)
    tail= sprintf("  #%s{",@name)
    leftName="Data"
    @records.each do |r|
      n=r.name.capitalize
      case r.type
      when "array"
        decode+= sprintf("  {%s, %sDataLeft} = decode_%s(%s,decode_%s),\n",n,n,r.type,leftName,r.addtion)
      else
        decode+=sprintf("  {%s, %sDataLeft} = decode_%s(%s),\n",n,n,r.type,leftName)
      end
      #decode+="\n"
      tail+=sprintf("%s = %s, ",r.name,r.name.capitalize)
      leftName = sprintf("%sDataLeft",r.name.capitalize)
    end
    tail.chomp!(" ")
    tail.chomp!(",")
    tail+="},\n"
    decode+= "  %s="%(@namecap) + tail;
    decode+= sprintf("  {%s, %s}.\n",@namecap, leftName )
  end

end

def Parser(path)
  file=open(path,"r")
  struct=nil
  struct_list=[]
  comment=""
  file.lines.each do |line|
    line.strip!
    next if  /===/ =~ line
    if line[0,1]=="#"
     comment=line[1..-1]
     next
    end
    next if line=="" and struct ==nil
    if line[-1,1]=="="
      struct=RStruct.new(line[0..-2], comment)
    elsif line==""
      struct_list << struct
      struct=nil
    else
      array=line.split(" ")
      struct.append(Record.new(array[0],array[1],array[2]))
    end
  end
  struct_list << struct
end

struct_list=Parser(PayLoadFile)

### show in the terminal
# struct_list.each do |struct|
#   puts struct.gen_record
#   puts struct.gen_encode
#   puts struct.gen_decode
# end

##生成记录文件
def GenRecord(struct_list)
  file=File.open(RecordPath,"w")
  file.write(file_head("this file is generated by tools."))
  struct_list.each do |struct|
    file.write(struct.gen_record)
  end
  file.close()
end

##生成编码文件
def GenIndian(struct_list)
  file=File.open(IndianPath,"w")
  file.write(file_head("this file is generated by tools"))
  #file.write("-module(indian).\n")
  #  file.write("-compile(export_all).\n")
  struct_list.each do |struct|
    file.write sprintf("%%%% %s\n",struct.name)
    file.write(struct.gen_encode)
    file.write("\n")
    file.write(struct.gen_decode)
    file.write("\n")
  end
  file.close()
end


GenRecord(struct_list)
GenIndian(struct_list)


#####################生成api宏.
class Api
  attr_accessor :type,:name,:payload,:desc, :module, :cls
  def initialize(type)
    @type=type
  end
  def show()
    puts sprintf("type:%s,name:%s,payload:%s",@type,@name,@payload)
  end

  def code_name()
    namecap=""
    payload.split("_").each do |n|
      namecap+=n.capitalize
    end
    namecap
  end

end

##解析api.txt文件.
#
def parse_api()
  path=ApiFile
  api_code=[]
  file=open(path,"r")
  puts(file.lines.count)
  api=nil
  complete=0
  api_list=[]
  file.lines.each do |line|
	  line.strip!
	  #去掉注释
	  next if line[0,1]=="#"
	  next if line==""
	  array=line.split(":")
    if array[0] == "packet_type"
      raise sprintf("%s this code %s is already used",ApiFile,array[1]) if api_code.include?(array[1])
      api_code << array[1]
      api=Api.new(array[1])
      complete=1
    elsif array[0]=="name"
      unless ["req","ack","ntf"].include?(array[1].split("_")[-1])
        raise "api name must be end with [req|ack|ntf]"
      end
      api.cls = array[1].split("_")[-1]
      api.name=array[1]
      complete=2
    elsif array[0]=="payload"
      api.payload=array[1]
      complete=3
    elsif array[0]=="desc"
      api.desc=array[1]
      complete=4
    elsif array[0]=="module"
      api.module=array[1]
      complete=5
    end
    
    if api.cls=="req" and complete==5
      api_list<< api
      complete=0
    elsif complete==4 and api.cls!="req"
      api_list<< api
      complete=0
    end
  end
  api_list
end

api_list=parse_api()

#产生api宏定义.
def gen_api_macro(api_list)
  file=File.open(ApiMacroPath,"w")
  file.write(file_head("this file is generated by tools. do not edit it by yourself."))
  api_list.each do |api|
    contents=sprintf("%%%% %s\n-define(PACKET_%s,%s).\n",api.desc,api.name.upcase,api.type)
    file.write(contents)
  end
  file.close()
end
#产生函数diapacher
def gen_dispacher(api_list)
  file=File.open( DispacherPath,"w")
  file.write( file_head(" this file is generated by tools. do not edit it by yourself." ) )
  file.write("-module(protocal_decoder).\n")
  file.write("-compile(export_all).\n")
  file.write("-include(\"record.hrl\").\n\n")
  file.write("-include(\"api.hrl\").\n\n")
  file.write("-include(\"error.hrl\").\n\n")
  #api_list_new=api_list.select { |api|
  #  /req$/ =~ api.name
  #}

  puts(api_list)
  api_list_new=api_list

  api_list_ntf=api_list.select { |api|
    /ntf$/ =~ api.name
  }

  ## 生成process
  api_list_new.each_with_index do |api,idx|
    #next unless /req$/ =~ api.name

    contents=sprintf("%%%% %s\n",api.desc)
    if api.payload=="null"
      contents+=sprintf("decode(?PACKET_%s, _Data)  ->\n",api.name.upcase)
    else
      contents+=sprintf("decode(?PACKET_%s, Data)  ->\n",api.name.upcase)
    end

    if api.payload!="null"
      contents+=sprintf("  protocal_payload:decode_%s(Data);\n\n", api.payload,api.payload)
    else
      contents+=sprintf("  {undefined, <<>>};\n\n")
    end

    file.write(contents)
  end

  file.write("decode(Type, _Data)  ->\n")
  file.write('  io:format("unkown type:~p\n",[Type]),'+"\n")
  file.write("  null.\n\n")

  file.close()
end

#产生replay函数
def gen_reply(api_list)
  file=File.open(EncoderPath, "w")
  file.write(file_head("this file is generated by tools. do not edit it by yourself."))
  file.write("-module(protocal_encoder).\n")
  file.write("-compile(export_all).\n")
  file.write("-include(\"record.hrl\").\n\n")
  file.write("-include(\"api.hrl\").\n\n")
  file.write("-include(\"error.hrl\").\n\n")
  file.write("-include(\"define.hrl\").\n\n")

  api_list.each do |api|
    #next if /req$/ =~ api.name
    contents=sprintf("%%%% %s\n",api.desc)
    if api.payload!="null"
      contents+=sprintf("encode(?PACKET_%s, %s=#%s{})  ->\n",
                        api.name.upcase, api.code_name, api.payload)
      contents+=sprintf("  Bin = protocal_payload:encode_%s(%s),\n",
                        api.payload, api.code_name)
    else
      contents+=sprintf("encode(?PACKET_%s, undefined)  ->\n",
                        api.name.upcase)
      contents+=sprintf("  Bin = <<>>,\n")
    end
    contents+=sprintf("  list_to_binary([<<?PACKET_%s:?HWORD>>, Bin]);\n\n",api.name.upcase)
    file.write(contents)
  end
  file.write("encode(_, _) ->\n  error.\n\n")
  file.close()
end


gen_api_macro(api_list)
gen_dispacher(api_list)
gen_reply(api_list)

class Error
  attr_reader :name,:number,:desc
  def initialize(name,number,desc)
    @name,@number,@desc=name,number,desc
  end
end

def parse_error()
  path=ErrorCodeFile
  file=open(path,"r")
  error_code=[]
  error_name=[]
  complete=0
  error_list=[]
  file.lines.each do |line|
    line.strip!
    #去掉注释
    #puts line
    next if line[0,1]=="#"
    array=line.split("-")
    raise sprintf("%s this code %s is already used ",ErrorCodeFile,array[0]) if error_code.include?(array[0])
    error_code<< array[0]

    raise sprintf("%s this name %s is already used",ErrorCodeFile,array[1]) if error_name.include?(array[1])
    error_name<< array[1]

    error_list << Error.new(array[1],array[0],array[2])
  end
  error_list
end

def gen_error_file(error_list)
  path=ErrorHeadPath
  file=open(path,"w")
  file.write(file_head("this file is generated by tools. do not edit it by yourself."))
  #file.write("-define(ACK_OK,0).%返回成功\n")
  error_list.each do |error|
    contents=sprintf("-define(ACK_%s,%s). %%%s\n",error.name.upcase,error.number,error.desc)
#    puts(contents)
    file.write(contents)
  end
  file.close()
end




error_list=parse_error()
gen_error_file(error_list)
