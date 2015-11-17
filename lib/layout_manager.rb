class LayoutMngr

	@@layoutMngr=nil

	def LayoutMngr.href_base(here)
		here=here.split(File::Separator)
		href_base=nil
		["dyndoc-proj","dyndocker"].each do |base|
			href_base='../'*(here.length-here.rindex(base)-2) if here.include? base
		end
		href_base || "./"
	end

	def LayoutMngr.register(type,id,content)
		@@layoutMngr=LayoutMngr.new unless @@layoutMngr
		@@layoutMngr.register(type,id,content)
	end

	def LayoutMngr.<<(arg)
		@@layoutMngr=LayoutMngr.new unless @@layoutMngr
		@@layoutMngr << arg
		@@layoutMngr
	end

	def LayoutMngr.header
		@@layoutMngr.header
	end

	def LayoutMngr.ids
		@@layoutMngr.ids
	end

	def LayoutMngr.regs
		@@layoutMngr.regs
	end

	def LayoutMngr.js_post
		@@layoutMngr.js_post
	end

	attr_accessor :ids, :regs

	def initialize
		@regs,@ids={},{}
		types=[:css_header,:css_code,:js_header,:js_code,:js_code_post]
		types.each{|type| @regs[type],@ids[type]={},[] }
	end

	def register(type,id,content)
		@regs[type.to_sym][id.to_sym]=content.strip
		#puts "#{type} #{id} registered!"
	end

	# Important: 
	# => arg is Array : arg[1] is a String representing code to import as is! 
	#    ex: [:css_header, ".ace_editor {\nborder: 1px solid lightgray;\n}\n"]
	# => arg is Symbol: arg[1] is the id related to @regs
	#    ex: css_header:ace
	def <<(arg) 
		if arg.is_a? Array and [:css_code,:js_code,:js_code_post].include? arg[0].to_sym
			@ids[arg[0].to_sym] << arg[1].to_s.strip
		elsif arg.is_a? String 
			opt=arg.split(":")
			@ids[opt[0].to_sym] << opt[1].to_sym
		end
		self
	end

	def header
		content=[]
		@ids[:css_header].uniq.each do |id|
			content << @regs[:css_header][id]
		end
		@ids[:js_header].uniq.each do |id|
			content << @regs[:js_header][id]
		end
		unless @ids[:css_code].empty?
			content << '<style type="text/css" media="screen">'
			@ids[:css_code].uniq.each do |id|
				content << ((id.is_a? Symbol) ? @regs[:css_code][id] : id)
			end
			content << '</style>'
		end
		unless @ids[:js_code].empty?
			content << '<script type="text/javascript">'
			@ids[:js_code].uniq.each do |id|
				#Dyndoc.warn "id",id
				content << ((id.is_a? Symbol) ? @regs[:js_code][id] : id)
			end
			content << '</script>'
		end
		return content.join("\n")
	end

	def js_post
		content=['<script type="text/javascript">']
		unless @ids[:js_code_post].empty?
			@ids[:js_code_post].uniq.each do |id|
				content << ((id.is_a? Symbol) ? @regs[:js_code_post][id] : id)
			end
			content << '</script>'
		end
		return content.join("\n")
	end
end