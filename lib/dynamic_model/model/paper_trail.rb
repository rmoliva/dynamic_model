#
# module DynamicModel
#   module Model
#     module PaperTrail
#       extend ::ActiveSupport::Concern
#
#       included do
#       end
# 
#       module ClassMethods
#         def use_dynamic_paper_trail options = {}
#           # Si no hay papertrail o no esta habilitado, no seguir
#           return unless (!defined?(::PaperTrail) or ::PaperTrail.enabled? == false)
#
#           # Habilitar papertrail para la tabla de atributos
#           Dynamic::Attributes.send(:has_paper_trail, options)
#         end
#       end
#     end
#   end
# end
