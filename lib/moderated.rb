require 'moderated/railtie' if defined?(Rails)

# Moderated
module Moderated #:nodoc:
    
  module Glue
    def self.included base
      base.class_eval do
        extend ClassMethods
      end
    end
  end
  
  module ClassMethods
    
    def moderated(options = {})
      options = {:flagged_column => 'flagged', :blocked_column => 'blocked'}.update(options)      
      
      @flagged_column = options[:flagged_column]
      @blocked_column = options[:blocked_column]
      
      include InstanceMethods
    end
    
    def flagged_column
      @flagged_column || nil
    end
    
    def blocked_column
      @blocked_column || nil
    end
    
    def flagged
      where(self.flagged_column.to_sym => true)
    end
    
    def unflagged
      where(self.flagged_column.to_sym => false)
    end
    
    def blocked
      where(self.blocked_column.to_sym => true)
    end
    
    def unblocked
      where(self.blocked_column.to_sym => false)
    end
    
    def approved
      where(["#{self.blocked_column} = ? AND #{self.flagged_column} = ?", false, false])
    end    
    
  end
  
  module InstanceMethods
    
    def flagged_column
      self.class.flagged_column
    end
    alias_method :flag_column, :flagged_column
    
    def blocked_column
      self.class.blocked_column
    end
    alias_method :block_column, :blocked_column
    
    def flagged?
      eval("self.#{flagged_column} == true")
    end
    
    def blocked? 
      eval("self.#{blocked_column} == true")
    end
    
    def approved?
      !self.flagged? && !self.blocked?
    end
    
    def flag!
      # don't re-flag items that were already moderated
      if self.moderated_at.blank? 
        self.update_attribute(flagged_column, true)
        self.after_flag if(self.respond_to?(:after_flag))
      end
    end

    def unflag!
      self.flagged      = false
      self.moderated_at = Time.now
      self.save
      
      self.after_unflag if(self.respond_to?(:after_unflag))
    end

    def block!
      self.flagged      = false
      self.blocked      = true
      self.moderated_at = Time.now
      self.save(false)
      
      self.after_block if(self.respond_to?(:after_block))
    end

    def unblock!
      self.flagged = self.blocked = false
      self.moderated_at = Time.now
      self.save(false)
      
      self.after_unblock if(self.respond_to?(:after_unblock))
    end
    
  end
  
end