package tn.esprit.devops.entities;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.io.Serializable;

@Getter
@Setter
@ToString
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level= AccessLevel.PRIVATE)
@Entity
public class Client implements Serializable {

    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    Long id;
    String nom;
    @Enumerated(EnumType.STRING)
    Genre genre;
    // address add the following attribute
    String adresse;
    // phone add the following attribute
    String telephone;

}
