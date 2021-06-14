extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Disable collisions until the projectile has been alive for a bit to avoid colliding with the shooter.
func _ready():
	$CollisionShape2D.disabled = true

func _on_AliveTimer_timeout():
	$CollisionShape2D.disabled = false
