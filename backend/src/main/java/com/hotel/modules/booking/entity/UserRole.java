package com.hotel.modules.booking.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

// ============================================================
// Composite Key class cho bảng UserRoles (user_id + role_id)
// ============================================================
@Setter
@Getter
@Embeddable
class UserRoleId implements Serializable {

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "role_id")
    private Integer roleId;

    public UserRoleId() {}

    public UserRoleId(Long userId, Integer roleId) {
        this.userId = userId;
        this.roleId = roleId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserRoleId that)) return false;
        return Objects.equals(userId, that.userId) && Objects.equals(roleId, that.roleId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, roleId);
    }

}

// ============================================================
// Entity chính
// ============================================================
@Getter
@Entity
@Table(name = "UserRoles")
public class UserRole {

    @Setter
    @EmbeddedId
    private UserRoleId id;

    @Setter
    @ManyToOne
    @MapsId("userId")                   // map field userId trong UserRoleId
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @MapsId("roleId")                   // map field roleId trong UserRoleId
    @JoinColumn(name = "role_id")
    private Role role;

    @Column(name = "assigned_at", nullable = false, updatable = false)
    private LocalDateTime assignedAt;

    @PrePersist
    public void prePersist() {
        this.assignedAt = LocalDateTime.now();
    }

    // ===== Getters & Setters =====

    public void setRole(Role role) { this.role = role; }

}