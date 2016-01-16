## Questions: peut être lent et placé directement dans le fichier "questions".
## A chaque session ce fichier est chargé en début et à chaque envoi d'une question aux utilisateurs...

class Question

	@@mngr=nil

	def Question.register(question)
		@@mngr=self.new unless @@mngr
		@@mngr.register(question)
		@@mngr.save_questions
	end

	@@question_form=nil
	@@question_form_index=".question_form_index"

	@@current_question_form=nil

	def Question.question_form_add(form=nil)
		p [:session_dirs,Question.session_dir,Question.session_root_dir]
		@@current_question_form=Pathname(Question.session_dir).relative_path_from(Pathname(Question.session_root_dir)).to_s unless form
		p [:form,@@current_question_form]
		filename=File.join(@@session_root_dir,@@question_form_index)
		@@question_form= (File.exist? filename) ? eval(File.read(filename)) : []
		@@question_form << @@current_question_form.strip
		@@question_form.uniq!
		# check if some forms are not orphaned!
		@@question_form.select!{|dir|
			File.exist? File.join(Question.session_root_dir,dir)
		}
		# save the form index
		File.open(filename,"w") do |f|
			f << @@question_form.inspect
		end
	end

	def Question.current_question_form
		@@current_question_form=Pathname(Question.session_dir).relative_path_from(Pathname(Question.session_root_dir)).to_s unless @@current_question_form
		@@current_question_form
	end



	def Question.question_form_list
		filename=File.join(@@session_root_dir,@@question_form_index)
		(File.exist? filename) ? eval(File.read(filename)) : []
	end

	@@session_dir,@@session_root_dir=nil

	def Question.session_dir(dir=nil)
		if dir
			@@session_dir=dir
			root=dir.dup
            root=File.expand_path(File.join(root,"..")) until File.exist? File.join(root,"admin") or root=="/"
            Question.session_root_dir(root) if root and root != "/"
            p [:dirs,@@session_dir,@@session_root_dir]
		else
			@@session_dir
		end
	end

	def Question.session_root_dir(dir=nil)
		if dir
			@@session_root_dir=dir
		else
			@@session_root_dir
		end
	end

	def initialize
		@questions={}
		@ids=[] #ids array
	end

	# question with form: {id: , question: "", type: "", answer: "", html: , ...}
	#
	def register(question)
		id=question[:id]
		@ids << id
		question.delete(:id)
		@questions[id]=question
	end

	def save_questions
		filename=File.join(Question.session_dir,"questions")
		p [:filename,filename]
		File.open(filename,"w") do |f|
			f << {
					ids: @ids.uniq,
					questions: @questions
				}.inspect
		end
		puts "#{filename} created!"
	end

end
