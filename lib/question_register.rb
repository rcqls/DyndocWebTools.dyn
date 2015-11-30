## Questions: peut être lent et placé directement dans le fichier "questions".
## A chaque session ce fichier est chargé en début et à chaque envoi d'une question aux utilisateurs...

class Question

	@@mngr=nil

	def Question.register(question)
		@@mngr=self.new unless @@mngr
		@@mngr.register(question)
		@@mngr.save_questions
	end

	@@session_dir=nil

	def Question.session_dir(dir=nil)
		if dir
			@@session_dir=dir
		else
			@@session_dir
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

	def save_questions(filename=File.join(Question.session_dir,"questions"))
		File.open(filename,"w") do |f|
			f << {
					ids: @ids.uniq,
					questions: @questions
				}.inspect
		end
		puts "#{filename} created!"
	end

end