{
    :pl => {
        :i18n => {
            :plural => {
                :keys => [:one, :few, :many], :rule => lambda {
                    |n| n.abs== 1 ? :one
                    : [2, 3, 4].include?(n.abs % 10) && ![12, 13, 14].include?(n.abs % 100) ? :few : :many
                }
            }
        }
    }
}