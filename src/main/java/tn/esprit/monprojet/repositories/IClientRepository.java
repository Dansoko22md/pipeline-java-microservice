package tn.esprit.monprojet.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import tn.esprit.monprojet.entities.Client;
@Repository
public interface IClientRepository extends JpaRepository<Client, Long> {
}