module CMSScanner
  module Finders
    class Finder
      # Module to provide an easy way to perform password attacks
      module BreadthFirstDictionaryAttack
        # @param [ Array<CMSScanner::User> ] users
        # @param [ Array<String> ] passwords
        # @param [ Hash ] opts
        # @option opts [ Boolean ] :show_progression
        #
        # @yield [ CMSScanner::User ] When a valid combination is found
        #
        # TODO: Make rubocop happy about metrics etc
        #
        # rubocop:disable all
        def attack(users, passwords, opts = {})
          create_progress_bar(total: users.size * passwords.size, show_progression: opts[:show_progression])
          queue_count = 0

          passwords.each_with_index do |password, password_index|
            # TODO: Maybe check if there are no more users to try ? (might be useful with large wordlist)
            users.select { |u| u.password.nil? }.each do |user|
              request = login_request(user.username, password)

              request.on_complete do |res|
                progress_bar.title = "Trying #{user.username} / #{password}"
                progress_bar.increment

                if valid_credentials?(res)
                  user.password = password

                  yield user

                  offset = progress_bar.total - progress_bar.progress < hydra.max_concurrency ? 2 : 1

                  progress_bar.total -= passwords.size - password_index - offset
                elsif errored_response?(res)
                  output_error(res)
                end
              end

              hydra.queue(request)
              queue_count += 1

              if queue_count >= hydra.max_concurrency
                hydra.run
                queue_count = 0
              end
            end
          end

          hydra.run
          progress_bar.stop
        end
        # rubocop:enable all

        # @param [ String ] username
        # param [ String ] password
        #
        # @return [ Typhoeus::Request ]
        def login_request(username, password)
          # To Implement in the finder related to the attack
        end

        # @param [ Typhoeus::Response ] response
        #
        # @return [ Boolean ] Whether or not credentials related to the request are valid
        def valid_credentials?(response)
          # To Implement in the finder related to the attack
        end

        # @param [ Typhoeus::Response ] response
        #
        # @return [ Boolean ] Whether or not something wrong happened
        #                     other than wrong credentials
        def errored_response?(response)
          # To Implement in the finder related to the attack
        end

        protected

        # @param [ Typhoeus::Response ] response
        def output_error(response)
          error = if response.timed_out?
                    'Request timed out.'
                  elsif response.code.zero?
                    "No response from remote server. WAF/IPS? (#{response.return_message})"
                  elsif response.code.to_s =~ /^50/
                    'Server error, try reducing the number of threads.'
                  else
                    "Unknown response received Code: #{response.code}\nBody: #{response.body}"
                  end

          progress_bar.log("Error: #{error}")
        end
      end
    end
  end
end
