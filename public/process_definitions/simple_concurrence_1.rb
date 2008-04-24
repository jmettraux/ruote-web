
class SimpleConcurrence1 < OpenWFE::ProcessDefinition

    description "a concurrence example"

    sequence do
        concurrence do
            participant :alpha
            participant :bravo
        end
        participant :alpha # to alpha once again
    end
end

